import SwiftUI

struct BalanceAdjuster: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	@ScaledMetric private var fontSize: CGFloat = 50

	@State private var amount: Decimal = 0
	// TODO: change to Enum
	@State private var isOutgoingTransaction = true
	@State private var isAskingForConfirmation = false

	let budget: Budget
	let category: Category

	var body: some View {
		NavigationView {
			Form {
				HStack(alignment: .firstTextBaseline) {
					Button {
						isOutgoingTransaction.toggle()
					} label: {
						Image(systemName: isOutgoingTransaction ? "minus.square.fill" : "plus.square.fill")
							.symbolRenderingMode(.hierarchical)
							.foregroundColor(isOutgoingTransaction ? .red : .green)
							.font(.system(size: fontSize, weight: .medium))
							.minimumScaleFactor(0.5)
					}
					CurrencyField(amount: $amount, fontSize: fontSize)
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
			.actionSheet(isPresented: $isAskingForConfirmation) {
				let sign = isOutgoingTransaction ? "-" : "+"
				return ActionSheet(
					title: Text("Saldo anpassen"),
					message: Text("Soll die Anpasung von \(sign)\(amount.formatted(.eur())) im Budget \(budget.name) wirklich durchgeführt werden?"),
					buttons: [
						.default(Text("Saldoanpassung bestätigen")) {
							model.adjustBalance(of: budget, of: category, by: (isOutgoingTransaction ? -1 : 1) * amount)
							dismiss()
						},
						.cancel()
					]
				)
			}
		}
	}

	var doneButton: some View {
		Button("Fertig") {
			isAskingForConfirmation = true
		}
		.disabled(amount == 0.0)
	}
}
