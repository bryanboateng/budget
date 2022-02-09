import SwiftUI

struct CategoryCreator: View {
    @Environment(\.dismiss) var dismiss
    
    @State var name = ""
    @State var color = CategoryColor.allCases.randomElement()!
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
                            let category = Category(context: PersistenceController.shared.container.viewContext)
                            category.id = UUID()
                            category.name = name.trimmingCharacters(in: .whitespaces)
                            category.color = color
                            PersistenceController.shared.save()
                            
                            dismiss()
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
        }
    }
}

struct CategoryCreator_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCreator()
    }
}
