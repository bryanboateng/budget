import Foundation

@MainActor
class Model: ObservableObject {
	@Published private(set) var budgets: Set<Budget>

	private let savePath = URL.documentsDirectory
		.appendingPathComponent("budgets")

	init() {
		do {
			let data = try Data(contentsOf: savePath)
			budgets = try JSONDecoder().decode(Set<Budget>.self, from: data)
		} catch {
			budgets = []
		}
	}

	func insert(_ budget: Budget) {
		budgets.insert(budget)
		save()
	}

	func update(budget id: Budget.ID, change: Budget.Change) {
		var budget = self[id]
		if let name = change.name {
			budget.name = name
		}
		if let symbol = change.symbol {
			budget.symbol = symbol
		}
		if let color = change.color {
			budget.color = color
		}
		if let mwe = change.monthlyAllocation {
			let adjustments = switch budget.strategy {
			case .noMonthlyAllocation(let finance):
				finance.balanceAdjustments
			case .withMonthlyAllocation(let finance):
				finance.balanceAdjustments
			}
			switch mwe {
			case .deactivate: budget.strategy = .noMonthlyAllocation(.init(balanceAdjustments: adjustments))
			case .activate(let money): budget.strategy = .withMonthlyAllocation(.init(balanceAdjustments: adjustments, monthlyAllocation: money))
			}
		}
		self[budget.id] = budget
		save()
	}

	func adjustBalance(ofBudget id: Budget.ID, by amount: Decimal) {
		var budget = self[id]
		switch budget.strategy {
		case .noMonthlyAllocation(let finance):
			var balanceAdjustments = finance.balanceAdjustments
			balanceAdjustments.insert(BalanceAdjustment(date: .now, amount: amount))
			budget.strategy = .noMonthlyAllocation(.init(balanceAdjustments: balanceAdjustments))
		case .withMonthlyAllocation(let finance):
			var balanceAdjustments = finance.balanceAdjustments
			balanceAdjustments.insert(BalanceAdjustment(date: .now, amount: amount))
			budget.strategy = .withMonthlyAllocation(.init(
				balanceAdjustments: balanceAdjustments,
				monthlyAllocation: finance.monthlyAllocation
			))
		}
		self[budget.id] = budget
		save()
	}

	func delete(_ budget: Budget) {
		budgets.remove(budget)
		save()
	}

	private func save() {
		do {
			let data = try JSONEncoder().encode(budgets)
			try data.write(to: savePath, options: [.atomic, .completeFileProtection])
		} catch {
			print("Unable to save data.")
		}
	}

	subscript(budgetID: Budget.ID) -> Budget {
		get {
			budgets.first { $0.id == budgetID }!
		}

		set(newValue) {
			let index = budgets.firstIndex { $0.id == budgetID }!
			budgets.remove(at: index)
			budgets.insert(newValue)
		}
	}
}
