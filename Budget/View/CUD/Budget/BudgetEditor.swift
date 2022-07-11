import SwiftUI

struct BudgetEditor: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var model: Model

	let category: Category
	let budget: Budget

	@State private var name: String
	@State private var symbol: String

	private var changesArePresent: Bool {
		budget.name != name || budget.symbol != symbol
	}

	var body: some View {
		NavigationStack {
			BudgetCanvas(name: $name, symbol: $symbol, color: category.color)
				.navigationTitle("Edit Budget")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel") {
							dismiss()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Done") {
							model.update(budget, of: category, withName: name.trimmingCharacters(in: .whitespacesAndNewlines), andSymbol: symbol)
							dismiss()
						}
						.disabled(
							name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
							symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
							!changesArePresent
						)
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
