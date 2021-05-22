import SwiftUI

struct PaymentPartyPickerBudgetsList: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var paymentParty: PaymentParty?
    
    @FetchRequest(
        entity: Budget.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Budget.name, ascending: true),
        ]
    ) private var budgets: FetchedResults<Budget>
    
    var body: some View {
        Form {
            List(budgets, id: \.self) { budget in
                Button {
                    presentationMode.wrappedValue.dismiss()
                    paymentParty = .budget(budget)
                } label: {
                    PaymentCreatorBudgetRow(budget: budget)
                }
            }
        }
        .navigationTitle("Budget auswählen")
    }
}

struct PaymentPartnerPickerBudgetsList_Previews: PreviewProvider {
    static var previews: some View {
        PaymentPartyPickerBudgetsList(paymentParty: .constant(nil))
    }
}
