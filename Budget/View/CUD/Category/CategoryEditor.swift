import SwiftUI

struct CategoryEditor: View {
	@Environment(\.dismiss) private var dismiss

	@State private var name: String
	@State private var color: Category.Color

	var completion: (String, Category.Color) -> Void

	init(category: Category, completion: @escaping (String, Category.Color) -> Void) {
		_name = State(initialValue: category.name)
		_color = State(initialValue: category.color)
		self.completion = completion
	}

	var body: some View {
		NavigationView {
			CategoryCanvas(name: $name, color: $color)
				.navigationTitle("Kategorie bearbeiten")
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Abbrechen") {
							dismiss()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Fertig") {
							completion(name, color)
							dismiss()
						}
						.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
					}
				}
		}
	}
}
