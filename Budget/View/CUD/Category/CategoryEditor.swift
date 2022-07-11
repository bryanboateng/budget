import SwiftUI

struct CategoryEditor: View {
	@Environment(\.dismiss) private var dismiss

	@State private var name: String
	@State private var color: Category.Color

	var completion: (String, Category.Color) -> Void

	var body: some View {
		NavigationStack {
			CategoryCanvas(name: $name, color: $color)
				.navigationTitle("Edit Category")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel") {
							dismiss()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Done") {
							completion(name, color)
							dismiss()
						}
						.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
					}
				}
		}
	}

	init(category: Category, completion: @escaping (String, Category.Color) -> Void) {
		_name = State(initialValue: category.name)
		_color = State(initialValue: category.color)
		self.completion = completion
	}
}
