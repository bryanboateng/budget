import SwiftUI

struct CategoryCreator: View {
    @Environment(\.dismiss) var dismiss
    
    @State var name = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                    .font(.title)
                    .multilineTextAlignment(.center)
                
                Section {
                    doneButton
                }
            }
            .navigationTitle("Neue Zahlung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    doneButton
                }
            }
        }
    }
    
    var doneButton: some View {
        Button("Fertig") {
            let category = Category(context: PersistenceController.shared.container.viewContext)
            category.id = UUID()
            category.name = name.trimmingCharacters(in: .whitespaces)
            PersistenceController.shared.save()
            
            dismiss()
        }
        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}

struct CategoryCreator_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCreator()
    }
}
