import SwiftUI

struct BudgetEditor: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	let category: Category
	let budget: Budget

	@State private var name: String
	@State private var symbol: String

	var body: some View {
		NavigationView {
			BudgetCanvas(name: $name, symbol: $symbol, color: category.color)
				.navigationTitle("Budget bearbeiten")
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Abbrechen") {
							dismiss()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Fertig") {
							model.update(budget, of: category, withName: name.trimmingCharacters(in: .whitespaces), andSymbol: symbol)
							dismiss()
						}
						.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
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
