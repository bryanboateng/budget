import SwiftUI

struct BalanceChanger: View {
    @Environment(\.dismiss) var dismiss
    
    @ScaledMetric private var fontSize: CGFloat = 50

    @State private var amount: Decimal = 0
    // TODO: change to Enum
    @State private var isOutgoingTransaction = true
    
    @ObservedObject var budget: Budget
    
    // !!!: Not used, but necessary for the department view to be refreshed upon employee updates
    var budgetCount: Int
    
    var body: some View {
        NavigationView {
            Form {
                HStack(alignment: .firstTextBaseline) {
                    Button {
                        isOutgoingTransaction.toggle()
                    } label: {
                        Image(systemName: isOutgoingTransaction ? "minus.square.fill" : "plus.square.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(isOutgoingTransaction ? .red : .green)
                            .font(.system(size: fontSize, weight: .medium))
                            .minimumScaleFactor(0.5)
                    }
                    CurrencyField(amount: $amount, fontSize: fontSize)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                
                Section(header: Text("Budget")) {
                    BudgetRow(budget: budget)
                }
                
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
                budget.balance = budget.balance!.subtracting(NSDecimalNumber(decimal: amount))
            } else {
                budget.balance = budget.balance!.adding(NSDecimalNumber(decimal: amount))
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
        
        return BalanceChanger(budget: budget, budgetCount: 0)
            .preferredColorScheme(.dark)
    }
}
