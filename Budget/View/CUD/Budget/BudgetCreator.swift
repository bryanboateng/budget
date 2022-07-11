import SwiftUI

struct BudgetCreator: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	let category: Category

	@State var name = ""
	@State var symbol = ""

	var body: some View {
		NavigationStack {
			BudgetCanvas(name: $name, symbol: $symbol, color: category.color)
				.navigationTitle("New Budget")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel") {
							dismiss()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Done") {
							let budget = Budget(name: name.trimmingCharacters(in: .whitespacesAndNewlines), symbol: symbol)
							model.insert(budget, into: category)
							dismiss()
						}
						.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
					}
				}
		}
	}
}
