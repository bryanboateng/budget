import SwiftUI

struct CategoryCreator: View {
    @EnvironmentObject private var model: Model
    @Environment(\.dismiss) var dismiss

    @State var name = ""
    @State var color = Category.Color.allCases.randomElement()!
    @State var symbol = Symbols.symbols.values.randomElement()!.randomElement()!

    
    var body: some View {
        NavigationView {
            CategoryCanvas(name: $name, color: $color)
                .navigationTitle("Neue Kategorie")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fertig") {
                            model.add(category: Category(name: name.trimmingCharacters(in: .whitespaces), color: color))
                            dismiss()
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
        }
    }
}
