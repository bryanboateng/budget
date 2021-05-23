import SwiftUI

struct ContactPaymentView: View {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    @ScaledMetric private var amountTextSize: CGFloat = 50
    @State private var isEditing = false
    
    let contactPayment: ContactPayment
    
    var body: some View {
        List {
            VStack {
                Text("\(contactPayment.direction == .incoming ? "+" : "")\(contactPayment.amount!, formatter: NumberFormatter.currency)")
                    .font(.system(size: amountTextSize, weight: .semibold, design: .rounded))
                    .foregroundColor(contactPayment.direction == .incoming ? .green : .primary)
                
                Text("\(contactPayment.date!, formatter: Self.dateFormatter)")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            
            Section(header: Text("Aufträger")) {
                switch contactPayment.direction {
                case .outgoing:
                    PaymentViewBudgetRow(budget: contactPayment.budget!)
                case .incoming:
                    Text(contactPayment.contact!)
                }
            }
            
            Section (header: Text("Begünstiger")) {
                switch contactPayment.direction {
                case .outgoing:
                    Text(contactPayment.contact!)
                case .incoming:
                    PaymentViewBudgetRow(budget: contactPayment.budget!)
                }
            }
            
            Section(header: Text("Verwendungszweck")) {
                Text(contactPayment.purpose!)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Bearbeiten") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            PaymentEditor(payment: contactPayment)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Zahlung")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContactPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let payment = ContactPayment(context: PersistenceController.preview.container.viewContext)
        payment.amount = 9.99
        payment.date = Date()
        payment.purpose = "Giotto"
        payment.contact = "HIT Ulrich"
        payment.direction = .incoming
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        payment.budget = budget
        
        return NavigationView {
            ContactPaymentView(contactPayment: payment)
        }
    }
}
