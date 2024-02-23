import IdentifiedCollections
import Foundation
import OrderedCollections

func groupBudgets(
	_ budgets: IdentifiedArrayOf<Account.Budget>
) -> OrderedDictionary<Account.Budget.Color, [Account.Budget]> {
	func comparisonValue(_ budget: Account.Budget) -> Decimal {
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
		Account.Budget.Color.allCases.compactMap { color in
			hello[color].map { budgets in
				(color, budgets)
			}
		},
		uniquingKeysWith: { (first, _) in first }
	)
}
