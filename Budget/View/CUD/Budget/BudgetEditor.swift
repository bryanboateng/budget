import SwiftUI

struct BudgetEditor: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var symbol = ""
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        if budget.isFault {
            EmptyView()
        } else {
            NavigationView {
                BudgetCanvas(name: $name, symbol: $symbol, color: budget.category!.color)
                    .navigationTitle("Budget bearbeiten")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Abbrechen") {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Fertig") {
                                budget.name = name.trimmingCharacters(in: .whitespaces)
                                budget.symbol = symbol
                                PersistenceController.shared.save()
                                dismiss()
                            }
                            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    .onAppear {
                        name = budget.name!
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
        
        return BudgetEditor(budget: budget)
    }
}
