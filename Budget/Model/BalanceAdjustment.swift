import Foundation

struct BalanceAdjustment: Codable, Identifiable {
	let id: UUID
	let date: Date
	let amount: Decimal

	init(date: Date, amount: Decimal) {
		self.id = UUID()
		self.date = date
		self.amount = amount
	}
}

extension BalanceAdjustment: Hashable {
	static func == (lhs: BalanceAdjustment, rhs: BalanceAdjustment) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
