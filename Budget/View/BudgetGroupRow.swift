//import SwiftUI
//
//struct BudgetGroupRow: View {
//	@EnvironmentObject private var model: Model
//	let budgets: Set<Budget>
//
//	var body: some View {
//		ForEach(
//			budgets.sorted { lhs, rhs in
//				if comparisonValue(lhs) == comparisonValue(rhs) {
//					return lhs.name < rhs.name
//				}
//				return comparisonValue(lhs) > comparisonValue(rhs)
//			}
//		) { budget in
//			NavigationLink {
//				BudgetDetail(budget: budget)
//					.environmentObject(model)
//			} label: {
//				BudgetRow(budget: budget)
//			}
//		}
//	}
//
//	private func comparisonValue(_ budget: Budget) -> Decimal {
//		if let projection = budget.projection {
//			return projection.discretionaryFunds
//		} else {
//			return budget.balance
//		}
//	}
//}
