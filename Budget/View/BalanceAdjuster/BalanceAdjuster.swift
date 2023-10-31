import SwiftUI

struct BalanceAdjuster: View {
	private enum Direction: CaseIterable {
		case outgoing
		case incoming
	}

	init(budget: Budget.ID) {
		_budgetID = State(initialValue: budget)
	}

	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	@ScaledMetric private var fontSize: CGFloat = 65
	@FocusState private var currencyFieldIsFocused: Bool

	@State private var absoluteAmount: Decimal = 0
	@State private var direction = Direction.outgoing

	@State private var budgetID: Budget.ID

	private var directionImageName: String {
		switch direction {
		case .outgoing: "minus"
		case .incoming: "plus"
		}
	}
	private var directionImageColor: Color {
		switch direction {
		case .outgoing: .red
		case .incoming: .green
		}
	}

	private func directionString(_ direction: Direction) -> String {
		switch direction {
		case .outgoing: "Ausgabe"
		case .incoming: "Einnahme"
		}
	}

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
		NavigationStack {
			Form {
				VStack(spacing: 0) {
					Label(directionString(direction), systemImage: directionImageName)
						.labelStyle(.iconOnly)
						.symbolVariant(.square)
						.symbolVariant(.fill)
						.foregroundStyle(directionImageColor)
						.font(.system(size: 24, weight: .semibold))
					CurrencyField(amount: $absoluteAmount, fontSize: fontSize)
						.focused($currencyFieldIsFocused)
					Text("EUR")
						.fontWeight(.semibold)
				}
				.frame(maxWidth: .infinity, alignment: .center)
				.listRowBackground(Color(UIColor.systemGroupedBackground))

				Section(header: Text("Budget")) {
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
				.pickerStyle(.navigationLink)

				Picker("Richtung", selection: $direction) {
					ForEach(Direction.allCases, id: \.self) { color in
						Text(directionString(color))
					}
				}
				.pickerStyle(.menu)

				Section {
					doneButton
				}
			}
			.onAppear {
				currencyFieldIsFocused = true
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
			let amount: Decimal = {
				switch direction {
				case .outgoing: -1 * absoluteAmount
				case .incoming: absoluteAmount
				}
			}()
			model.adjustBalance(ofBudget: budgetID, by: amount)
			dismiss()
		}
		.disabled(absoluteAmount == 0.0)
	}
}
