import SwiftUI

struct CategoryRow: View {
	@EnvironmentObject private var model: Model

	let category: Category

	var body: some View {
		ForEach(
			category.budgets.sorted { lhs, rhs in
				if lhs.currentBalance == rhs.currentBalance {
					return lhs.name < rhs.name
				}
				return lhs.currentBalance > rhs.currentBalance
			}
		) { budget in
			NavigationLink {
				BudgetDetail(budget: budget, category: category)
					.environmentObject(model)
			} label: {
				BudgetRow(budget: budget, color: category.color)
			}
		}
	}
}
