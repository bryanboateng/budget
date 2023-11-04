import Foundation
import SwiftUI

struct Budget: Codable, Identifiable, Hashable {
	let id: UUID
	var name: String
	var symbol: String
	var color: Color
	var balanceAdjustments: Set<BalanceAdjustment> = []

	var balance: Decimal {
		balanceAdjustments.reduce(0) { partialResult, balanceAdjustment in
			partialResult + balanceAdjustment.amount
		}
	}

	private var monthlyAllocation: Decimal?

	init(name: String, symbol: String, color: Color, monthlyAllocation: Decimal? = nil) {
		self.id = UUID()
		self.name = name
		self.symbol = symbol
		self.color = color
		self.monthlyAllocation = monthlyAllocation
	}

	mutating func setMonthlyAllocation(_ monthlyAllocation: Decimal) {
		self.monthlyAllocation = monthlyAllocation
	}

	mutating func removeMonthlyAllocation() {
		self.monthlyAllocation = nil
	}

	mutating func adjustBalance(_ amount: Decimal) {
		balanceAdjustments.insert(.init(date: .now, amount: amount))
	}

	var projection: Projection? {
		guard let monthlyAllocation else { return nil }
		return .init(monthlyAllocation: monthlyAllocation, balance: balance)
	}

	struct Projection {
		let monthlyAllocation: Decimal
		private let currentBalance: Decimal

		init(monthlyAllocation: Decimal, balance: Decimal) {
			self.monthlyAllocation = monthlyAllocation
			self.currentBalance = balance
		}

		private var totalDaysInCurrentMonth: Int {
			let calendar = Calendar.current
			let interval = calendar.dateInterval(of: .month, for: .now)!
			return calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
		}

		var projectedBalance: Decimal {
			let todaysDayNumber = Calendar.current.dateComponents([.day], from: .now).day!
			return monthlyAllocation * (1 - (Decimal(todaysDayNumber) / Decimal(totalDaysInCurrentMonth)))
		}

		var discretionaryFunds: Decimal {
			currentBalance - projectedBalance
		}

		var discretionaryDays: Decimal {
			let dailyAllocation = monthlyAllocation / Decimal(totalDaysInCurrentMonth)
			return discretionaryFunds / dailyAllocation
		}
	}

	enum Color: String, CaseIterable, Codable {
		case red
		case orange
		case yellow
		case green
		case mint
		case teal
		case cyan
		case blue
		case indigo
		case purple
		case pink
		case brown

		var swiftUIColor: SwiftUI.Color {
			switch self {
			case .red: .red
			case .orange: .orange
			case .yellow: .yellow
			case .green: .green
			case .mint: .mint
			case .teal: .teal
			case .cyan: .cyan
			case .blue: .blue
			case .indigo: .indigo
			case .purple: .purple
			case .pink: SwiftUI.Color("CustomPink")
			case .brown: .brown
			}
		}

		var localizedName: String {
			switch self {
			case .red: "Rot"
			case .orange: "Orange"
			case .yellow: "Gelb"
			case .green: "Grün"
			case .mint: "Minze"
			case .teal: "Türkis"
			case .cyan: "Zyan"
			case .blue: "Blau"
			case .indigo: "Indigo"
			case .purple: "Lila"
			case .pink: "Rosa"
			case .brown: "Braun"
			}
		}
	}

	struct BalanceAdjustment: Codable, Identifiable, Hashable {
		let id: UUID
		let date: Date
		let amount: Decimal

		init(date: Date, amount: Decimal) {
			self.id = UUID()
			self.date = date
			self.amount = amount
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.id == rhs.id
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}

	struct Change {
		let name: String?
		let symbol: String?
		let color: Color?
		let projection: Projection?

		enum Projection {
			case deactivate
			case activate(Decimal)
		}
	}
}
