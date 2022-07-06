import SwiftUI

struct BalanceHistory: View {
	@Environment(\.dismiss) private var dismiss

	let budget: Budget

	var body: some View {
		NavigationStack {
			Group {
				if budget.balanceAdjustments.isEmpty {
					Text("Keine Historie.")
						.foregroundStyle(.secondary)
				} else {
					List {
						ForEach(budget.balanceAdjustments.sorted { $0.date > $1.date }) { adjustment in
							HStack {
								Text(adjustment.date.formatted(.dateTime.day().month().hour().minute().second()))
									.foregroundStyle(.secondary)
								Spacer()
								Text(adjustment.amount.formatted(.eur().sign(strategy: .accountingAlways())))
							}
						}
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Fertig") {
						dismiss()
					}
				}
			}
			.navigationTitle(budget.name)
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

struct BalanceHistory_Previews: PreviewProvider {
	static var previews: some View {
		BalanceHistory(budget: Budget(name: "Urlaub", symbol: "globe.europe.africa"))
	}
}
