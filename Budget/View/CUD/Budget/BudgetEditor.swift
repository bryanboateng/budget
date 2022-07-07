import SwiftUI

struct BudgetEditor: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	let category: Category
	let budget: Budget

	@State private var name: String
	@State private var symbol: String

	var body: some View {
		NavigationStack {
			BudgetCanvas(name: $name, symbol: $symbol, color: category.color)
				.navigationTitle("Budget bearbeiten")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Abbrechen") {
							dismiss()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Fertig") {
							model.update(budget, of: category, withName: name.trimmingCharacters(in: .whitespacesAndNewlines), andSymbol: symbol)
							dismiss()
						}
						.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
					}
				}
		}
	}

	init(budget: Budget, category: Category) {
		self.budget = budget
		self.category = category

		_name = State(initialValue: budget.name)
		_symbol = State(initialValue: budget.symbol)
	}
}
