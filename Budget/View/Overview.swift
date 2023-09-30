import SwiftUI

struct Overview: View {
	@EnvironmentObject private var model: Model

	@State private var isCreatingBudget = false

	private var totalBalance: Decimal {
		model.budgets.reduce(0) { partialResult, budget in
			let amount = switch budget.strategy {
			case .noMonthlyAllocation(let finance):
				finance.balance
			case .withMonthlyAllocation(let finance):
				finance.currentBalance
			}
			return partialResult + amount
		}
	}

	private var groupedBudgets: Dictionary<Budget.Color, [Budget]> {
		.init(grouping: model.budgets) { budget in
			budget.color
		}
	}

	var body: some View {
		Group {
			if model.budgets.isEmpty {
				ContentUnavailableView {
					Label("Keine Budgets", systemImage: "circle")
				}
			} else {
				List {
					BalanceDisplay(balance: totalBalance)
					ForEach(
						Budget.Color.allCases.filter { color in
							groupedBudgets.keys.contains(color)
						}
						, id: \.self
					){ color in
						Section {
							BudgetGroupRow(budgets: Set<Budget>(groupedBudgets[color]!))
						} header: {
							Text(color.localizedName)
						}
					}
				}
			}
		}
		.navigationTitle("Konto")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					isCreatingBudget = true
				} label: {
					Label("Kategorien", systemImage: "circle.badge.plus")
				}
			}
			ToolbarItemGroup(placement: .bottomBar) {
				Spacer()
				Button("Saldo anpassen", systemImage: "arrow.left.arrow.right") {
				}
			}
		}
		.sheet(isPresented: $isCreatingBudget) {
			BudgetCreator()
		}
	}
}
private struct BalanceDisplay: View {
	let balance: Decimal

	var body: some View {
		VStack(alignment: .leading) {
			Text("Kontostand")
				.foregroundStyle(.secondary)
				.font(.subheadline)
			Text(balance, format: .eur())
				.font(.title)
				.fontWeight(.semibold)
		}
	}
}
