import Foundation

extension FormatStyle where Self == Decimal.FormatStyle.Currency {
	static func eur() -> Self {
		.currency(code: "EUR")
	}
}
