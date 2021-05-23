import SwiftUI

struct BudgetPaymentView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    @ScaledMetric private var amountTextSize: CGFloat = 50
    @State private var isAskingForDeletionConformation = false
    
    let budgetPayment: BudgetPayment
    let shownDirection: PaymentDirection
    
    var body: some View {
        if budgetPayment.isFault {
            EmptyView()
        } else {
            List {
                VStack {
                    Text("\(shownDirection == .incoming ? "+" : "")\(budgetPayment.amount!, formatter: NumberFormatter.currency)")
                        .font(.system(size: amountTextSize, weight: .semibold, design: .rounded))
                        .foregroundColor(shownDirection == .incoming ? .green : .primary)
                    
                    Text("\(budgetPayment.date!, formatter: Self.dateFormatter)")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                
                Section(header: Text("Aufträger")) {
                    PaymentViewBudgetRow(budget: budgetPayment.sender!)
                }
                
                Section (header: Text("Begünstiger")) {
                    PaymentViewBudgetRow(budget: budgetPayment.receiver!)
                }
                
                Section(header: Text("Verwendungszweck")) {
                    Text(budgetPayment.purpose!)
                }
                
                Button("Zahlung löschen") {
                    isAskingForDeletionConformation = true
                }
                .foregroundColor(.red)
            }
            .actionSheet(isPresented: $isAskingForDeletionConformation) {
                ActionSheet(
                    title: Text("Zahlung löschen"),
                    message: Text("Soll die Zahlung wirklich gelöscht werden?"),
                    buttons: [
                        .destructive(Text("Zahlung löschen")) {
                            presentationMode.wrappedValue.dismiss()
                            PersistenceController.shared.container.viewContext.delete(budgetPayment)
                            PersistenceController.shared.save()
                        },
                        .cancel()
                    ]
                )
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Zahlung")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BudgetPaymentView_Previews: PreviewProvider {
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
        
        return NavigationView {
            BudgetPaymentView(budgetPayment: payment, shownDirection: .incoming)
        }
    }
}
