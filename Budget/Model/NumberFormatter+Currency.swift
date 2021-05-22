import Foundation

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "EUR"
        return numberFormatter
    }()
}
