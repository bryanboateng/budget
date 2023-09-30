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
				switch budget.strategy {
				case .noMonthlyAllocation(let finance):
					Text(finance.balance, format: .eur())
				case .withMonthlyAllocation(let finance):
					Text("• \(finance.discretionaryFunds, format: .eur())")
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
		color: .red,
		strategy: .noMonthlyAllocation(.init(balanceAdjustments: []))
	)
	let budget2 = Budget(
		name: "Moinsen",
		symbol: "chair",
		color: .green,
		strategy: .withMonthlyAllocation(.init(
			balanceAdjustments: [],
			monthlyAllocation: 89.2
		))
	)
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
