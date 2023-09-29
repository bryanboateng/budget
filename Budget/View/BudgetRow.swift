import SwiftUI

struct BudgetRow: View {
	let budget: Budget
	let color: Category.Color

	private var ewf: Text {
		Text(
			"(T \(budget.currentBalance.formatted(.number.precision(.fractionLength(2)))))"
		)
		.foregroundStyle(.secondary)
		.font(.subheadline)
	}

	private var balanceText: Text {
		Text(budget.spendableBalance, format: .eur())
	}

	var body: some View {
		HStack {
			Label {
				Text(budget.name)
					.multilineTextAlignment(.leading)
			} icon: {
				Image(systemName: budget.symbol)
					.font(.title3)
					.foregroundStyle(color.swiftUIColor)
			}
			Spacer()
			Text("\(ewf) \(balanceText)")
		}
		.foregroundColor(.primary)
	}
}

#Preview {
	NavigationStack {
		List(0..<100) { _ in
			Menu {
				Text("Lorem")
			} label: {
				BudgetRow(budget: Budget(name: "Moinsen", symbol: "figure.bowling"), color: .red)
			}
		}
	}
}
