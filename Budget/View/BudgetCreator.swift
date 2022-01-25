import SwiftUI

struct BudgetCreator: View {
    @Environment(\.dismiss) var dismiss
    
    let category: Category
    
    @State var budgetName = ""
    @State var color = BudgetColor.allCases.randomElement()!
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    Circle()
                        .foregroundColor(color.swiftUIColor)
                        .frame(width: 120, height: 120)
                    TextField("Name", text: $budgetName)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    ColorPicker(selectedColor: $color)
                }
                .padding(.top, 60)
                .padding(Edge.Set.all.subtracting(.top))
            }
            .navigationTitle("Neues Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        let budget = Budget(context: PersistenceController.shared.container.viewContext)
                        budget.id = UUID()
                        budget.name = budgetName.trimmingCharacters(in: .whitespaces)
                        budget.color = color
                        budget.category = category
                        PersistenceController.shared.save()
                        
                        dismiss()
                    }
                    .disabled(budgetName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            
        }
    }
}

struct BudgetCreator_Previews: PreviewProvider {
    static var previews: some View {
        let category = Category(context: PersistenceController.preview.container.viewContext)
        category.id = UUID()
        category.name = "Regularly"
        
        return BudgetCreator(category: category)
    }
}
