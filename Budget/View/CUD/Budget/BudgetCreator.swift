import SwiftUI

struct BudgetCreator: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	let category: Category

	@State var name = ""
	@State var symbol = ""

	var body: some View {
		NavigationView {
			BudgetCanvas(name: $name, symbol: $symbol, color: category.color)
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
							let budget = Budget(name: name.trimmingCharacters(in: .whitespaces), symbol: symbol)
							model.insert(budget, into: category)
							dismiss()
						}
						.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
					}
				}
		}
	}
}
