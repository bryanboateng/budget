import SwiftUI

struct BudgetCreator: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	@State private var name = ""
	@State private var symbol = ""
	@State private var showGreeting = false
	@State private var grenze: Decimal = 0
	@State private var color = Budget.Color.allCases.randomElement()!

	var body: some View {
		NavigationStack {
			BudgetCanvas(
				name: $name,
				symbol: $symbol,
				showGreeting: $showGreeting,
				grenze: $grenze,
				color: $color
			)
			.navigationTitle("Neues Budget")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Abbrechen") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Fertig") {
						let budget = Budget(
							name: name.trimmingCharacters(in: .whitespacesAndNewlines),
							symbol: symbol,
							color: color,
							strategy: {
								if showGreeting {
									return .withMonthlyAllocation(AllocatedFinance(balanceAdjustments: [], monthlyAllocation: grenze))
								} else {
									return .noMonthlyAllocation(NonAllocatedFinance(balanceAdjustments: []))
								}
							}()
						)

						model.insert(budget)
						dismiss()
					}
					.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
			}
		}
	}
}
