import SwiftUI

struct BudgetRow: View {
	let budget: Budget

	var body: some View {
		HStack {
			Group {
				if #available(iOS 17, *) {
					Label {
						Text(budget.name)
					} icon: {
						Image(systemName: budget.symbol)
							.foregroundStyle(budget.color.swiftUIColor)
					}
				} else {
					HStack {
						Image(systemName: budget.symbol)
							.foregroundStyle(budget.color.swiftUIColor)
							.font(.title3)
						Text(budget.name)
					}
				}
			}
			.multilineTextAlignment(.leading)
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
