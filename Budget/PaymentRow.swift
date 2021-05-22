import SwiftUI

struct PaymentRow: View {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    let payment: Payment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(payment.purpose!)
                    .font(.headline)
                Spacer()
                Text("\(payment.amount! as Decimal > 0 ? "+" : "")\(NSDecimalNumber(decimal: abs((payment.amount! as Decimal))), formatter: Self.currencyFormatter)")
                    .font(.system((payment.amount! as Decimal) > 0 ? .headline : .body, design: .rounded))
                    .foregroundColor((payment.amount! as Decimal) > 0 ? .green : .primary)
            }
            Text("\(payment.party!) - \(payment.date!, formatter: Self.dateFormatter)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemFill))
        .cornerRadius(16)
    }
}

struct PaymentRow_Previews: PreviewProvider {
    static var previews: some View {
        
        let payment = Payment(context: PersistenceController.preview.container.viewContext)
        payment.amount = 9.99
        payment.date = Date()
        payment.party = "Bryan"
        payment.purpose = "Giotto"
        
        return PaymentRow(payment: payment)
            .previewLayout(.sizeThatFits)
    }
}
