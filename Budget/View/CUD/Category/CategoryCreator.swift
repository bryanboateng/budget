import SwiftUI

struct CategoryCreator: View {
	@Environment(\.dismiss) private var dismiss
	@State private var name = ""
	@State private var color = Category.Color.allCases.randomElement()!

	var completion: (Category) -> Void

	var body: some View {
		NavigationStack {
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
							completion(Category(name: name.trimmingCharacters(in: .whitespacesAndNewlines), color: color))
							dismiss()
						}
						.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
					}
				}
		}
	}
}

#Preview {
	CategoryCreator { _ in }
}
