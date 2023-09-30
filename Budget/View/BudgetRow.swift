import SwiftUI

struct BudgetRow: View {
	let budget: Budget
	let color: Category.Color

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
			if let reality = budget.weofnopwe {
				let ewf = Text(
					"(\(budget.currentBalance.formatted(.number.precision(.fractionLength(2)))))"
				)
					.foregroundStyle(.secondary)
					.font(.subheadline)
				let balanceText = Text(reality.spendableBalance, format: .eur())
				Text("\(ewf) \(balanceText)")
			} else {
				Text(budget.currentBalance, format: .eur())
			}
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
