import SwiftUI

struct BudgetRow: View {
	let budget: Budget

	var body: some View {
		HStack {
			Label {
				Text(budget.name)
					.multilineTextAlignment(.leading)
			} icon: {
				Image(systemName: budget.symbol)
					.font(.title3)
					.foregroundStyle(budget.color.swiftUIColor)
			}
			Spacer()
			Group {
				if let projection = budget.projection {
					Text("• \(projection.discretionaryFunds, format: .eur())")
				} else {
					Text(budget.balance, format: .eur())
				}
			}
			.monospacedDigit()
		}
		.foregroundColor(.primary)
	}
}

#Preview {
	let budget1 = Budget(
		name: "Moinsen",
		symbol: "figure.bowling",
		color: .red
	)
	var budget2 = Budget(
		name: "Moinsen",
		symbol: "chair",
		color: .green
	)
	budget2.setMonthlyAllocation(89.2)
	return NavigationStack {
		List(0..<100) { _ in
			Menu {
				Text("Lorem")
			} label: {
				BudgetRow(budget: budget1)
			}
			Menu {
				Text("Lorem")
			} label: {
				BudgetRow(budget: budget2)
			}
		}
	}
}
