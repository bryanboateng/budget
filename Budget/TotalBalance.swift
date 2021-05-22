import SwiftUI

struct TotalBalance: View {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    let amount: NSDecimalNumber
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(amount, formatter: Self.currencyFormatter)")
                .bold()
                .font(.system(.title2, design: .rounded))
            Text("Gesamter Stand")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct TotalBalance_Previews: PreviewProvider {
    static var previews: some View {
        TotalBalance(amount: 1204.63)
    }
}
