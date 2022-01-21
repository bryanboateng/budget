import SwiftUI

struct TotalBalance: View {
    let amount: NSDecimalNumber
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(amount.decimalValue.formatted(.eur()))
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
