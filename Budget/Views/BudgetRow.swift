import SwiftUI

struct BudgetRow: View {
	let budget: Budget

	var body: some View {
		HStack {
			Text(budget.name)
				.multilineTextAlignment(.leading)
			Spacer()
			Group {
				if let projection = budget.projection {
					Text("• \(projection.discretionaryFunds, format: .eur())")
				} else {
					Text(budget.balance, format: .eur())
				}
			}
			.foregroundStyle(.secondary)
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
