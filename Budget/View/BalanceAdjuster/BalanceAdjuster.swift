import SwiftUI

struct BalanceAdjuster: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	@ScaledMetric private var fontSize: CGFloat = 50

	@State private var absoluteAmount: Decimal = 0
	@State private var sign = FloatingPointSign.minus

	let budget: Budget
	let category: Category

	var body: some View {
		NavigationStack {
			Form {
				HStack(alignment: .firstTextBaseline) {
					Button {
						switch sign {
						case .minus:
							sign = .plus
						case .plus:
							sign = .minus
						}
					} label: {
						let symbol: String = {
							switch sign {
							case .minus:
								return "minus.square.fill"
							case .plus:
								return "plus.square.fill"
							}
						}()
						let symbolColor: Color = {
							switch sign {
							case .minus:
								return .red
							case .plus:
								return .green
							}
						}()
						Image(systemName: symbol)
							.symbolRenderingMode(.hierarchical)
							.foregroundStyle(symbolColor)
							.font(.system(size: fontSize, weight: .medium))
							.minimumScaleFactor(0.5)
					}
					CurrencyField(amount: $absoluteAmount, fontSize: fontSize)
				}
				.frame(maxWidth: .infinity, alignment: .center)
				.listRowBackground(Color(UIColor.systemGroupedBackground))

				Section(header: Text("Budget")) {
					BudgetRow(budget: budget, color: category.color)
				}

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

	var doneButton: some View {
		Button("Fertig") {
			let amount: Decimal = {
				switch sign {
				case .minus:
					return -1 * absoluteAmount
				case .plus:
					return absoluteAmount
				}
			}()
			model.adjustBalance(of: budget, of: category, by: amount)
			dismiss()
		}
		.disabled(absoluteAmount == 0.0)
	}
}
