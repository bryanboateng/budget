import Foundation

struct Budget: Codable, Identifiable, Hashable {
	let id: UUID
	var name: String
	var symbol: String
	var balanceAdjustments: Set<BalanceAdjustment> = []
	let monthlyAllocation: Decimal = 10

	var currentBalance: Decimal {
		balanceAdjustments.reduce(0) { partialResult, balanceAdjustment in
			partialResult + balanceAdjustment.amount
		}
	}

	var plannedBalance: Decimal {
		let todaysDayNumber = Calendar.current.dateComponents([.day], from: .now).day!
		return monthlyAllocation * (1 - (Decimal(todaysDayNumber) / Decimal(totalDaysInCurrentMonth)))
	}

	var spendableBalance: Decimal {
		currentBalance - plannedBalance
	}

	var spendableDays: Decimal {
		let dailyAllocation = monthlyAllocation / Decimal(totalDaysInCurrentMonth)
		return spendableBalance / dailyAllocation
	}

	private var totalDaysInCurrentMonth: Int {
		let calendar = Calendar.current
		let interval = calendar.dateInterval(of: .month, for: .now)!
		return calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
	}

	init(name: String, symbol: String) {
		self.id = UUID()
		self.name = name
		self.symbol = symbol
	}
}
