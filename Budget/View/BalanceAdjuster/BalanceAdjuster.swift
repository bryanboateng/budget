import SwiftUI

struct BalanceAdjuster: View {
	private enum Direction: CaseIterable {
		case outgoing
		case incoming

		mutating func toggle() {
			switch self {
			case .outgoing:
				self = .incoming
			case .incoming:
				self = .outgoing
			}
		}
	}

	private enum AdjustmentType: CaseIterable {
		case single
		case transfer
	}

	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	@ScaledMetric private var fontSize: CGFloat = 65

	@State private var absoluteAmount: Decimal = 0
	@State private var direction = Direction.outgoing
	@State private var adjustmentType = AdjustmentType.single

	@State private var primaryBudgetID: Budget.ID
	@State private var secondaryBudgetID: Budget.ID

	init(primaryBudgetID: Budget.ID) {
		_primaryBudgetID = State(initialValue: primaryBudgetID)

		if let uuidString = UserDefaults
			.standard
			.string(
				forKey: UserDefaultKeys.idOfLastBudgetReceivingTransfer.rawValue
			)
		{
			_secondaryBudgetID = State(initialValue: UUID(uuidString: uuidString)!)
		} else {
			_secondaryBudgetID = State(initialValue: primaryBudgetID)
		}
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					AdjustmentTypePicker(adjustmentType: $adjustmentType)
				}
				switch adjustmentType {
				case .single:
					SingleAdjustmentView(
						fontSize: fontSize,
						budgetID: $primaryBudgetID,
						direction: $direction,
						absoluteAmount: $absoluteAmount
					)
				case .transfer:
					TransferAdjustmentView(
						fontSize: fontSize,
						senderID: $primaryBudgetID,
						receiverID: $secondaryBudgetID,
						amount: $absoluteAmount
					)
				}
				Section {
					doneButton
				}
			}
			.navigationTitle("Saldo anpassen")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Abbrechen") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					doneButton
				}
			}
		}
	}

	private var doneButton: some View {
		Button("Fertig") {
			UserDefaults
				.standard
				.set(
					primaryBudgetID.uuidString,
					forKey: UserDefaultKeys.latestPrimaryBudgetID.rawValue
				)
			switch adjustmentType {
			case .single:
				let amount: Decimal = {
					switch direction {
					case .outgoing: -1 * absoluteAmount
					case .incoming: absoluteAmount
					}
				}()
				model.adjustBalance(ofBudget: primaryBudgetID, by: amount)
			case .transfer:
				UserDefaults
					.standard
					.set(
						secondaryBudgetID.uuidString,
						forKey: UserDefaultKeys.idOfLastBudgetReceivingTransfer.rawValue
					)
				model.adjustBalance(ofBudget: primaryBudgetID, by: -1 * absoluteAmount)
				model.adjustBalance(ofBudget: secondaryBudgetID, by:  absoluteAmount)
			}
			dismiss()
		}
		.disabled(absoluteAmount == 0.0)
	}

	private struct BudgetPicker: View {
		@EnvironmentObject private var model: Model
		@Binding var budgetID: Budget.ID

		private var groupedBudgets: [Budget.Color: [Budget]] {
			.init(grouping: model.budgets) { budget in
				budget.color
			}
		}
		private func comparisonValue(_ budget: Budget) -> Decimal {
			if let projection = budget.projection {
				return projection.discretionaryFunds
			} else {
				return budget.balance
			}
		}
		var body: some View {
			Picker(selection: $budgetID, label: EmptyView()) {
				ForEach(
					Budget.Color.allCases.filter { color in
						groupedBudgets.keys.contains(color)
					}
					, id: \.self
				) { color in
					ForEach(
						groupedBudgets[color]!.sorted { lhs, rhs in
							if comparisonValue(lhs) == comparisonValue(rhs) {
								return lhs.name < rhs.name
							}
							return comparisonValue(lhs) > comparisonValue(rhs)
						}
					) { budget in
						BudgetRow(budget: budget)
							.tag(budget.id)
					}
				}
			}
		}
	}

	private struct AdjustmentTypePicker: View {
		private func adjustmentTypeString(_ type: AdjustmentType) -> String {
			switch type {
			case .single: "Einzel"
			case .transfer: "Übertrag"
			}
		}
		@Binding var adjustmentType: AdjustmentType

		var body: some View {
			Picker("Art", selection: $adjustmentType) {
				ForEach(AdjustmentType.allCases, id: \.self) { color in
					Text(adjustmentTypeString(color))
				}
			}
			.pickerStyle(.menu)
		}
	}

	private struct SingleAdjustmentView: View {
		let fontSize: CGFloat
		@Binding var budgetID: Budget.ID
		@Binding var direction: Direction
		@Binding var absoluteAmount: Decimal
		@FocusState var currencyFieldIsFocused: Bool

		private func directionString(_ direction: Direction) -> String {
			switch direction {
			case .outgoing: "Ausgabe"
			case .incoming: "Einnahme"
			}
		}

		var body: some View {
			Section("Budget") {
				BudgetPicker(budgetID: $budgetID)
			}
			.pickerStyle(.navigationLink)
			CurrencyFieldSection(
				fontSize: fontSize,
				absoluteAmount: $absoluteAmount,
				direction:  direction,
				isFocused: $currencyFieldIsFocused
			)
			.onAppear {
				currencyFieldIsFocused = true
			}
			Picker("Richtung", selection: $direction) {
				ForEach(Direction.allCases, id: \.self) { color in
					Text(directionString(color))
				}
			}
			.pickerStyle(.menu)
		}
	}

	private struct TransferAdjustmentView: View {
		let fontSize: CGFloat
		@Binding var senderID: Budget.ID
		@Binding var receiverID: Budget.ID
		@Binding var amount: Decimal
		@FocusState var currencyFieldIsFocused: Bool

		var body: some View {
			Section("Sender") {
				BudgetPicker(budgetID: $senderID)
			}
			.pickerStyle(.navigationLink)
			Section("Empfänger") {
				BudgetPicker(budgetID: $receiverID)
			}
			.pickerStyle(.navigationLink)
			CurrencyFieldSection(
				fontSize: fontSize,
				absoluteAmount: $amount,
				direction: nil,
				isFocused: $currencyFieldIsFocused
			)
			.onAppear {
				currencyFieldIsFocused = true
			}
		}
	}

	private struct CurrencyFieldSection: View {
		let fontSize: CGFloat
		@Binding var absoluteAmount: Decimal
		let direction: Direction?
		@FocusState<Bool>.Binding var isFocused: Bool

		private var sign: FloatingPointSign? {
			switch direction {
			case .outgoing: return .minus
			case .incoming: return .plus
			case .none: return nil
			}
		}

		var body: some View {
			Section("Betrag") {
				CurrencyField(amount: $absoluteAmount, sign: sign, fontSize: fontSize)
					.focused($isFocused)
					.frame(maxWidth: .infinity, alignment: .center)
			}
		}
	}
}
