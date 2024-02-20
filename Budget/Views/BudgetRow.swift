import SwiftUI

struct BudgetRow: View {
	let budget: Budget

	var body: some View {
		HStack {
			Image(systemName: "circlebadge")
				.foregroundStyle(budget.color.swiftUIColor)
				.symbolVariant(.fill)
				.imageScale(.small)
			Text(budget.name)
		}
		.badge(badge)
	}

	var badge: Text {
		if let projection = budget.projection {
			return Text("• \(projection.discretionaryFunds, format: .eur())")
		} else {
			return Text(budget.balance, format: .eur())
		}
	}
}

#Preview {
	let budget1 = Budget(
		id: UUID(),
		name: "Moinsen",
		color: .red
	)
	var budget2 = Budget(
		id: UUID(),
		name: "Moinsen",
		color: .green
	)
	budget2.setMonthlyAllocation(89.2)
	return NavigationStack {
		List(0..<100) { _ in
			BudgetRow(budget: budget1)
			BudgetRow(budget: budget2)
		}
	}
}
