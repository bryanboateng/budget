import SwiftUI

struct Category: Codable, Identifiable, Hashable {
	let id: UUID
	var name: String
	var color: Color
	var budgets: Set<Budget> = []

	var totalBalance: Decimal {
		budgets.reduce(0) { partialResult, budget in
			partialResult + budget.balance
		}
	}

	init(id: Category.ID, name: String, color: Color) {
		self.id = id
		self.name = name
		self.color = color
	}

	init(name: String, color: Color) {
		self.id = UUID()
		self.name = name
		self.color = color
	}

	subscript(budgetID: Budget.ID) -> Budget {
		get {
			budgets.first { $0.id == budgetID }!
		}

		set(newValue) {
			budgets.remove(at: budgets.firstIndex { $0.id == budgetID }!)
			budgets.insert(newValue)
		}
	}
}

extension Category {
	enum Color: CaseIterable, Codable {
		case red
		case orange
		case yellow
		case green
		case teal
		case blue
		case purple
		case pink

		var swiftUIColor: SwiftUI.Color {
			switch self {
			case .red:
				return SwiftUI.Color.red
			case .orange:
				return SwiftUI.Color.orange
			case .yellow:
				return SwiftUI.Color.yellow
			case .green:
				return SwiftUI.Color.green
			case .teal:
				return SwiftUI.Color(UIColor.systemTeal)
			case .blue:
				return SwiftUI.Color.blue
			case .purple:
				return SwiftUI.Color.purple
			case .pink:
				return SwiftUI.Color("pink")
			}
		}
	}
}
