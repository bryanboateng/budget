import SwiftUI

struct BudgetGroupRow: View {
	@EnvironmentObject private var model: Model
	let budgets: Set<Budget>

	var body: some View {
		ForEach(
			budgets.sorted { lhs, rhs in
				if comparisonValue(lhs) == comparisonValue(rhs) {
					return lhs.name < rhs.name
				}
				return comparisonValue(lhs) > comparisonValue(rhs)
			}
		) { budget in
			NavigationLink {
				BudgetDetail(budget: budget)
					.environmentObject(model)
			} label: {
				BudgetRow(budget: budget)
			}
		}
	}
	private func comparisonValue(_ budget: Budget) -> Decimal {
		switch budget.strategy {
		case .noMonthlyAllocation(let ogvi):
			return ogvi.balance
		case .withMonthlyAllocation(let mdonw):
			return mdonw.discretionaryFunds
		}
	}
}
