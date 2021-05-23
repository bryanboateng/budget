import SwiftUI

struct ContactPaymentRow: View {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    let contactPayment: ContactPayment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(contactPayment.purpose!)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(contactPayment.direction == .incoming ? "+" : "")\(contactPayment.amount!, formatter: NumberFormatter.currency)")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(contactPayment.direction == .incoming ? .green : .primary)
            }
            Text("\(contactPayment.date!, formatter: Self.dateFormatter)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct ContactPaymentRow_Previews: PreviewProvider {
    static var previews: some View {
        
        let payment = ContactPayment(context: PersistenceController.preview.container.viewContext)
        payment.amount = 9.99
        payment.date = Date()
        payment.purpose = "Giotto"
        payment.contact = "HIT Ulrich"
        payment.direction = .incoming
        
        return ContactPaymentRow(contactPayment: payment)
            .previewLayout(.sizeThatFits)
    }
}
