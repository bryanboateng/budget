import SwiftUI

struct PaymentEditor: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var isAskingForDeletionConformation = false
    @ObservedObject var payment: Payment
    
    var body: some View {
        NavigationView {
            Form {
                Button("Zahlung löschen") {
                    isAskingForDeletionConformation = true
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Zahlung bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .actionSheet(isPresented: $isAskingForDeletionConformation) {
                ActionSheet(
                    title: Text("Zahlung löschen"),
                    message: Text("Soll die Zahlung wirklich gelöscht werden?"),
                    buttons: [
                        .destructive(Text("Zahlung löschen")) {
                            PersistenceController.shared.container.viewContext.delete(payment)
                            PersistenceController.shared.save()
                            presentationMode.wrappedValue.dismiss()
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
}

struct PaymentEditor_Previews: PreviewProvider {
    static var previews: some View {
        
        let payment = BudgetPayment(context: PersistenceController.preview.container.viewContext)
        payment.amount = 9.99
        payment.date = Date()
        payment.purpose = "Giotto"
        
        let sender = Budget(context: PersistenceController.preview.container.viewContext)
        sender.name = "Lebensmittel"
        sender.color = .pink
        
        let receiver = Budget(context: PersistenceController.preview.container.viewContext)
        receiver.name = "TU Berlin"
        receiver.color = .green
        
        payment.sender = sender
        payment.receiver = receiver
        
        return PaymentEditor(payment: payment)
            .preferredColorScheme(.dark)
    }
}
