import SwiftUI


struct BudgetCreator: View {
    @Environment(\.dismiss) var dismiss
    
    let category: Category
    
    @State var budgetName = ""
    @State var color = BudgetColor.allCases.randomElement()!
    @State var symbol = Symbols.symbols.values.randomElement()!.randomElement()!
    
    var body: some View {
        NavigationView {
            BudgetCanvas(name: $budgetName, color: $color, symbol: $symbol)
                .navigationTitle("Neues Budget")
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
                            budget.symbol = symbol
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
