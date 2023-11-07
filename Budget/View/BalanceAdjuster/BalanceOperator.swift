import SwiftUI

struct BalanceOperator: View {
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

	private enum Operation: CaseIterable {
		case adjustment
		case transfer
	}

	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	@ScaledMetric private var fontSize: CGFloat = 65

	@State private var absoluteAmount: Decimal = 0
	@State private var direction = Direction.outgoing
	@State private var operation = Operation.adjustment

	@State private var primaryBudgetID: Budget.ID
	@State private var secondaryBudgetID: Budget.ID
	@FocusState var currencyFieldIsFocused: Bool

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
				CurrencyField(
					amount: $absoluteAmount,
					sign: {
						switch operation {
						case .adjustment:
							switch direction {
							case .outgoing: return .minus
							case .incoming: return .plus
							}
						case .transfer:
							return nil
						}
					}(),
					fontSize: fontSize
				)
				.focused($currencyFieldIsFocused)
				.frame(maxWidth: .infinity, alignment: .center)
				.listRowBackground(Color(UIColor.systemGroupedBackground))
				switch operation {
				case .adjustment:
					AdjustmentView(
						budgetID: $primaryBudgetID,
						direction: $direction
					)
				case .transfer:
					TransferView(
						senderID: $primaryBudgetID,
						receiverID: $secondaryBudgetID
					)
				}
				Section {
					doneButton
				}
			}
			.onAppear {
				currencyFieldIsFocused = true
			}
			.navigationTitle("Saldo-Operation")
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
				ToolbarItem(placement: .principal) {
					Picker("Saldo-Operation", selection: $operation) {
						Text("Anpassung").tag(Operation.adjustment)
						Text("Umbuchung").tag(Operation.transfer)
					}
					.pickerStyle(.segmented)
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
			switch operation {
			case .adjustment:
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

	private struct AdjustmentView: View {
		@Binding var budgetID: Budget.ID
		@Binding var direction: Direction

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
			Picker("Richtung", selection: $direction) {
				ForEach(Direction.allCases, id: \.self) { color in
					Text(directionString(color))
				}
			}
			.pickerStyle(.menu)
		}
	}

	private struct TransferView: View {
		@Binding var senderID: Budget.ID
		@Binding var receiverID: Budget.ID

		var body: some View {
			Section("Sender") {
				BudgetPicker(budgetID: $senderID)
			}
			.pickerStyle(.navigationLink)
			Section("Empfänger") {
				BudgetPicker(budgetID: $receiverID)
			}
			.pickerStyle(.navigationLink)
		}
	}
}
