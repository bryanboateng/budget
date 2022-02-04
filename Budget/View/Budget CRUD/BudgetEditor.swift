import SwiftUI

struct BudgetEditor: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var budgetName = ""
    @State private var color = BudgetColor.green
    @State private var symbol = ""
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        if budget.isFault {
            EmptyView()
        } else {
            NavigationView {
                BudgetCanvas(name: $budgetName, color: $color, symbol: $symbol)
                    .navigationTitle("Budget bearbeiten")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Abbrechen") {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Fertig") {
                                budget.name = budgetName.trimmingCharacters(in: .whitespaces)
                                budget.color = color
                                budget.symbol = symbol
                                PersistenceController.shared.save()
                                dismiss()
                            }
                            .disabled(budgetName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    .onAppear {
                        budgetName = budget.name!
                        color = budget.color
                        symbol = budget.symbol!
                    }
            }
        }
    }
}

struct BudgetEditor_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return BudgetEditor(budget: budget)
    }
}
