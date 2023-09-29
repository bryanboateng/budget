import SwiftUI

struct BalanceAdjuster: View {
	private enum Direction: CaseIterable {
		case outgoing
		case incoming
	}

	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	@ScaledMetric private var fontSize: CGFloat = 65

	@State private var absoluteAmount: Decimal = 4.45
	@State private var direction = Direction.outgoing

	let budget: Budget
	let category: Category

	private var weof: Text {
		Text(
			absoluteAmount,
			format: .number.precision(.fractionLength(2))
		)
		.font(.system(size: fontSize, weight: .semibold))
	}
	private var directionImageName: String {
		switch direction {
		case .outgoing: "minus"
		case .incoming: "plus"
		}
	}
	private var directionImageColor: Color {
		switch direction {
		case .outgoing: .red
		case .incoming: .green
		}
	}

	private func directionString(_ direction: Direction) -> String {
		switch direction {
		case .outgoing: "Ausgabe"
		case .incoming: "Einnahme"
		}
	}

	var body: some View {
		NavigationStack {
			Form {
				VStack {
					Label(directionString(direction), systemImage: directionImageName)
						.labelStyle(.iconOnly)
						.symbolVariant(.square)
						.symbolVariant(.fill)
						.foregroundStyle(directionImageColor)
						.font(.system(size: 24, weight: .semibold))

					Text("\(weof)\nEUR")
						.fontWeight(.semibold)
						.multilineTextAlignment(.center)
					//					CurrencyField(amount: $absoluteAmount, fontSize: fontSize)
					//						.border(.green)
				}
				.frame(maxWidth: .infinity, alignment: .center)
				.listRowBackground(Color(UIColor.systemGroupedBackground))

				Section(header: Text("Budget")) {
					BudgetRow(budget: budget, color: category.color)
				}

				Picker("Richtung", selection: $direction) {
					ForEach(Direction.allCases, id: \.self) { color in
						Text(directionString(color))
					}
				}
				.pickerStyle(.menu)

				Section {
					doneButton
				}
			}
			.navigationTitle("Saldo anpassen")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Abbrechen") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					doneButton
				}
			}
		}
	}

	private var doneButton: some View {
		Button("Fertig") {
			let amount: Decimal = {
				switch direction {
				case .outgoing: -1 * absoluteAmount
				case .incoming: absoluteAmount
				}
			}()
			model.adjustBalance(of: budget, of: category, by: amount)
			dismiss()
		}
		.disabled(absoluteAmount == 0.0)
	}
}

#Preview {
	BalanceAdjuster(
		budget: Budget(name: "fe", symbol: "gear"),
		category: Category(name: "Employee", color: .green)
	)
}
