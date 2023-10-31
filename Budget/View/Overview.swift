import SwiftUI

struct Overview: View {
	@EnvironmentObject private var model: Model

	@State private var isCreatingBudget = false
	@State private var historyIsOpen = false

	private var totalBalance: Decimal {
		model.budgets.reduce(0) { partialResult, budget in
			partialResult + budget.balance
		}
	}

	private var groupedBudgets: [Budget.Color: [Budget]] {
		.init(grouping: model.budgets) { budget in
			budget.color
		}
	}

	var body: some View {
		Group {
			if model.budgets.isEmpty {
				if #available(iOS 17, *) {
					ContentUnavailableView("Keine Budgets", systemImage: "folder")
				} else {
					Text("Keine Budgets")
				}
			} else {
				List {
					BalanceDisplay(balance: totalBalance)
					ForEach(
						Budget.Color.allCases.filter { color in
							groupedBudgets.keys.contains(color)
						}
						, id: \.self
					) { color in
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
					historyIsOpen = true
				} label: {
					Label("Verlauf", systemImage: "clock")
				}
			}
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					isCreatingBudget = true
				} label: {
					Label("Kategorien", systemImage: "folder.badge.plus")
				}
			}
			ToolbarItemGroup(placement: .bottomBar) {
				Spacer()
				Button("Saldo anpassen", systemImage: "eurosign") {
				}
				.symbolVariant(.circle)
			}
		}
		.sheet(isPresented: $isCreatingBudget) {
			BudgetCreator()
		}
		.sheet(isPresented: $historyIsOpen) {
			BalanceHistory(budgets: model.budgets)
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
