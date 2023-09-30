import Foundation
import SwiftUI

struct Budget: Codable, Identifiable, Hashable {
	let id: UUID
	var name: String
	var symbol: String
	var color: Color
	var strategy: Strategy

	init(name: String, symbol: String, color: Color, strategy: Strategy) {
		self.id = UUID()
		self.name = name
		self.symbol = symbol
		self.color = color
		self.strategy = strategy
	}

	enum Color: CaseIterable, Codable {
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
		case gray

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
			case .gray: .gray
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
			case .gray: "Grau"
			}
		}
	}

	struct Change {
		let name: String?
		let symbol: String?
		let color: Color?
		let monthlyAllocation: Oewo?

		enum Oewo {
			case deactivate
			case activate(Decimal)
		}
	}
}

enum Strategy: Codable, Hashable {
	case noMonthlyAllocation(NonAllocatedFinance)
	case withMonthlyAllocation(AllocatedFinance)
}

struct AllocatedFinance: Codable, Hashable {
	let balanceAdjustments: Set<BalanceAdjustment>
	let monthlyAllocation: Decimal

	var currentBalance: Decimal {
		balanceAdjustments.reduce(0) { partialResult, balanceAdjustment in
			partialResult + balanceAdjustment.amount
		}
	}

	var totalDaysInCurrentMonth: Int {
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
struct NonAllocatedFinance: Codable, Hashable {
	let balanceAdjustments: Set<BalanceAdjustment>
	var balance: Decimal {
		balanceAdjustments.reduce(0) { partialResult, balanceAdjustment in
			partialResult + balanceAdjustment.amount
		}
	}
}
