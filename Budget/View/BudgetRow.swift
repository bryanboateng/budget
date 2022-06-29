import SwiftUI

struct BudgetRow: View {
	@Environment(\.colorScheme) var colorScheme
	let budget: Budget
	let color: Category.Color

	var body: some View {
		Label {
			Text(budget.name)
				.multilineTextAlignment(.leading)
		} icon: {
			Image(systemName: budget.symbol)
				.font(.title2)
				.foregroundStyle(color.swiftUIColor)
		}
		.badge(budget.balance.formatted(.eur()))
		.foregroundColor(.primary)
	}
}
