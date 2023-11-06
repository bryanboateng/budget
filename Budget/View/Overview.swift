import SwiftUI

struct Overview: View {
	@AppStorage(UserDefaultKeys.latestPrimaryBudgetID.rawValue) private var lastUsedBudgetIDString = ""
	@EnvironmentObject private var model: Model

	@State private var isCreatingBudget = false
	@State private var isAdjustingBalance = false
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
				ContentUnavailableView("Keine Budgets", systemImage: "folder")
			} else {
				List {
					BalanceDisplay(balance: totalBalance)
					ForEach(
						Budget.Color.allCases.filter { color in
							groupedBudgets.keys.contains(color)
						}
						, id: \.self
					) { color in
						Section(color.localizedName) {
							BudgetGroupRow(budgets: Set<Budget>(groupedBudgets[color]!))
						}
					}
				}
			}
		}
		.navigationTitle("Konto")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					historyIsOpen = true
				} label: {
					Label("Verlauf", systemImage: "clock")
				}
			}
			ToolbarItem(placement: .bottomBar) {
				Button {
					isCreatingBudget = true
				} label: {
					Label("Kategorien", systemImage: "folder.badge.plus")
				}
			}
			ToolbarItemGroup(placement: .bottomBar) {
				Spacer()
				Button("Saldo anpassen", systemImage: "eurosign") {
					isAdjustingBalance = true
				}
				.symbolVariant(.circle)
				.disabled(groupedBudgets.isEmpty)
			}
		}
		.sheet(isPresented: $isCreatingBudget) {
			BudgetCreator()
		}
		.fullScreenCover(isPresented: $historyIsOpen) {
			BalanceHistory(budgets: model.budgets)
		}
		.sheet(isPresented: $isAdjustingBalance) {
			BalanceAdjuster(
				primaryBudgetID:
					UUID(uuidString: lastUsedBudgetIDString) ?? model.budgets.randomElement()!.id
			)
			.environmentObject(model)
		}
	}
}

private struct BalanceDisplay: View {
	let balance: Decimal

	var body: some View {
		HStack {
			Label {
				Text("Kontostand")
			} icon: {
				Image(systemName: "building.columns")
			}
			Spacer()
			Text(balance, format: .eur())
				.monospacedDigit()
		}
		.foregroundColor(.secondary)
	}
}
