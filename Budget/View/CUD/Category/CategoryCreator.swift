import SwiftUI

struct CategoryCreator: View {
	@Environment(\.dismiss) private var dismiss
	@State private var name = ""
	@State private var color = Category.Color.allCases.randomElement()!

	var completion: (Category) -> Void

	var body: some View {
		NavigationView {
			CategoryCanvas(name: $name, color: $color)
				.navigationTitle("Neue Kategorie")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Abbrechen") {
							dismiss()
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						Button("Fertig") {
							completion(Category(name: name.trimmingCharacters(in: .whitespaces), color: color))
							dismiss()
						}
						.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
					}
				}
		}
	}
}
