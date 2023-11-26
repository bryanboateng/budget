import IdentifiedCollections
import Foundation
import OrderedCollections

func groupBudgets(
	_ budgets: IdentifiedArrayOf<Budget>
) -> OrderedDictionary<Budget.Color, [Budget]> {
	func comparisonValue(_ budget: Budget) -> Decimal {
		if let projection = budget.projection {
			return projection.discretionaryFunds
		} else {
			return budget.balance
		}
	}
	
	let hello = Dictionary(grouping: budgets) { budget in
		budget.color
	}
		.mapValues { budgets in
			budgets.sorted { lhs, rhs in
				if comparisonValue(lhs) == comparisonValue(rhs) {
					return lhs.name < rhs.name
				}
				return comparisonValue(lhs) > comparisonValue(rhs)
			}
		}
	
	return OrderedDictionary(
		Budget.Color.allCases.compactMap { color in
			hello[color].map { budgets in
				(color, budgets)
			}
		},
		uniquingKeysWith: { (first, _) in first }
	)
}
