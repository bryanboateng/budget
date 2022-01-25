import SwiftUI

struct BalanceChanger: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: Decimal = 0
    // TODO: change to Enum
    @State private var isOutgoingTransaction = false
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        NavigationView {
            Form {
                CurrencyField(amount: $amount)
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                
                Toggle("Show welcome message", isOn: $isOutgoingTransaction)
                
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
            if isOutgoingTransaction {
                budget.balance = budget.balance!.adding(NSDecimalNumber(decimal: amount))
            } else {
                budget.balance = budget.balance!.subtracting(NSDecimalNumber(decimal: amount))
            }
            PersistenceController.shared.save()
            
            dismiss()
        }
        .disabled(amount == 0.0)
    }
}

struct PaymentCreator_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return BalanceChanger(budget: budget)
            .preferredColorScheme(.dark)
    }
}
