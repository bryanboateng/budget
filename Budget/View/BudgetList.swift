import SwiftUI

struct BudgetList: View {
	@EnvironmentObject private var model: Model

	@State private var budgetBeingEdited: Budget?
	@State private var budgetAdjustingBalance: Budget?
	@State private var budgetBeingDeleted: Budget?
	@State private var budgetWhosHistoryIsShown: Budget?

	let category: Category

	var body: some View {
		ForEach(
			category.budgets.sorted { lhs, rhs in
				if lhs.balance == rhs.balance {
					return lhs.name < rhs.name
				}
				return lhs.balance > rhs.balance
			}
		) { budget in
			Menu {
				Button {
					budgetAdjustingBalance = budget
				} label: {
					Label("Adjust Balance", systemImage: "arrow.left.arrow.right")
				}

				Button {
					budgetWhosHistoryIsShown = budget
				} label: {
					Label("History", systemImage: "clock")
				}

				Button {
					budgetBeingEdited = budget
				} label: {
					Label("Edit", systemImage: "pencil")
				}

				Button(role: .destructive) {
					budgetBeingDeleted = budget
				} label: {
					Label("Delete", systemImage: "trash")
				}
			} label: {
				BudgetRow(budget: budget, color: category.color)
			}
		}
		.sheet(item: $budgetBeingEdited) { budget in
			BudgetEditor(budget: budget, category: category)
		}
		.sheet(item: $budgetAdjustingBalance) { budget in
			BalanceAdjuster(budget: budget, category: category)
		}
		.sheet(item: $budgetWhosHistoryIsShown) { budget in
			BalanceHistory(budget: budget)
		}
		.actionSheet(item: $budgetBeingDeleted) { budget in
			ActionSheet(
				title: Text("Delete \(budget.name)"),
				message: Text("Are you sure you want to delete the budget \(budget.name)? You can’t undo this action."),
				buttons: [
					.destructive(Text("Delete Budget")) {
						model.delete(budget, of: category)
					},
					.cancel()
				]
			)
		}
	}
}
