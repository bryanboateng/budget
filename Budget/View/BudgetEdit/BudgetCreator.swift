import SwiftUI

struct BudgetCreator: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	@State private var name = ""
	@State private var symbol = ""
	@State private var color = Budget.Color.allCases.randomElement()!
	@State private var projectionIsEnabled = false
	@State private var monthlyAllocation: Decimal = 0

	var body: some View {
		NavigationStack {
			BudgetCanvas(
				name: $name,
				symbol: $symbol,
				color: $color,
				projectionIsEnabled: $projectionIsEnabled,
				monthlyAllocation: $monthlyAllocation
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
						var budget = Budget(
							name: name.trimmingCharacters(in: .whitespacesAndNewlines),
							symbol: symbol,
							color: color
						)
						if projectionIsEnabled {
							budget.setMonthlyAllocation(monthlyAllocation)
						}

						model.insert(budget)
						dismiss()
					}
					.disabled(
						name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
						symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
					)
				}
			}
		}
	}
}
