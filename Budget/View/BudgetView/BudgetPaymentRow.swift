import SwiftUI

struct BudgetPaymentRow: View {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var otherParty: Budget {
        switch shownDirection {
        case .incoming:
            return budgetPayment.sender!
        case .outgoing:
            return budgetPayment.receiver!
        }
    }
    
    let budgetPayment: BudgetPayment
    let shownDirection: PaymentDirection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .frame(width: 6)
                    .foregroundColor(otherParty.color.swiftUIColor)
                Text(budgetPayment.purpose!)
                    .font(.headline)
                Spacer()
                Text("\(shownDirection == .incoming ? "+" : "")\(budgetPayment.amount!, formatter: NumberFormatter.currency)")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(shownDirection == .incoming ? .green : .primary)
            }
            Text("\(budgetPayment.date!, formatter: Self.dateFormatter)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct BudgetPaymentRow_Previews: PreviewProvider {
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
        
        return BudgetPaymentRow(budgetPayment: payment, shownDirection: .incoming)
            .previewLayout(.sizeThatFits)
    }
}
