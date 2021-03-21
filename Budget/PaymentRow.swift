//
//  PaymentRow.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 21.03.21.
//

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
                Text(payment.purpose)
                    .font(.headline)
                Spacer()
                Text("\(payment.amount > 0 ? "+" : "")\(NSNumber(value: abs(payment.amount)), formatter: Self.currencyFormatter)")
                    .font(.system(payment.amount > 0 ? .headline : .body, design: .rounded))
                    .foregroundColor(payment.amount > 0 ? .green : .primary)
            }
            Text("\(payment.party) - \(payment.date, formatter: Self.dateFormatter)")
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
        PaymentRow(payment: Payment(party: "Convini", purpose: "Snacks", amount: 9.99, date: Date()))
            .previewLayout(.sizeThatFits)
    }
}
