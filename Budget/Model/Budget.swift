import Foundation

struct Reality {
	let monthlyAllocation: Decimal
	let plannedBalance: Decimal
	let spendableBalance: Decimal
	let spendableDays: Decimal
}
struct Budget: Codable, Identifiable, Hashable {
	let id: UUID
	var name: String
	var symbol: String
	var balanceAdjustments: Set<BalanceAdjustment> = []

	private var monthlyAllocation: Decimal?

	mutating func owefn(monthlyAllocation: Decimal) {
		self.monthlyAllocation = monthlyAllocation
	}

	var weofnopwe: Reality? {
		guard let monthlyAllocation else { return nil }

		let totalDaysInCurrentMonth: Int = {
			let calendar = Calendar.current
			let interval = calendar.dateInterval(of: .month, for: .now)!
			return calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
		}()
		let plannedBalance: Decimal = {
			let todaysDayNumber = Calendar.current.dateComponents([.day], from: .now).day!
			return monthlyAllocation * (1 - (Decimal(todaysDayNumber) / Decimal(totalDaysInCurrentMonth)))
		}()

		let spendableBalance = currentBalance - plannedBalance

		let spendableDays: Decimal = {
			let dailyAllocation = monthlyAllocation / Decimal(totalDaysInCurrentMonth)
			return spendableBalance / dailyAllocation
		}()

		return Reality(
			monthlyAllocation: monthlyAllocation,
			plannedBalance: plannedBalance,
			spendableBalance: spendableBalance,
			spendableDays: spendableDays
		)
	}

	var currentBalance: Decimal {
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
