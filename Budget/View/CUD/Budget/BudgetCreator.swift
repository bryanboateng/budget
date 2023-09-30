import SwiftUI

struct BudgetCreator: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	let category: Category

	@State var name = ""
	@State var symbol = ""
	@State var showGreeting = false
	@State var grenze: Decimal = 0

	var body: some View {
		NavigationStack {
			BudgetCanvas(
				name: $name,
				symbol: $symbol,
				showGreeting: $showGreeting,
				grenze: $grenze,
				color: category.color
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
						var budget = Budget(name: name.trimmingCharacters(in: .whitespacesAndNewlines), symbol: symbol)
						if showGreeting {
							budget.owefn(monthlyAllocation: grenze)
						}
						model.insert(budget, into: category)
						dismiss()
					}
					.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
			}
		}
	}
}
