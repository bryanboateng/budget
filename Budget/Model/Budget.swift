import Foundation

struct Budget: Codable, Identifiable, Hashable {
	let id: UUID
	var name: String
	var symbol: String
	var balanceAdjustments: Set<BalanceAdjustment> = []

	var balance: Decimal {
		balanceAdjustments.reduce(0) { partialResult, balanceAdjustment in
			partialResult + balanceAdjustment.amount
		}
	}

	init(name: String, symbol: String) {
		self.id = UUID()
		self.name = name
		self.symbol = symbol
	}
}
