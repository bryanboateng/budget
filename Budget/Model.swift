import Foundation

@MainActor
class Model: ObservableObject {
	@Published private(set) var budgets: Set<Budget>

	private let saveURL = URL.documentsDirectory
		.appending(component: "budgets")
		.appendingPathExtension("json")

	init() {
		do {
			let data = try Data(contentsOf: saveURL)
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
		if let monthlyAllocation = change.projection {
			switch monthlyAllocation {
			case .deactivate: budget.removeMonthlyAllocation()
			case .activate(let amount): budget.setMonthlyAllocation(amount)
			}
		}
		self[id] = budget
		save()
	}

	func adjustBalance(ofBudget id: Budget.ID, by amount: Decimal) {
		var budget = self[id]
		budget.adjustBalance(amount)
		self[id] = budget
		save()
		UserDefaults.standard.set(id.uuidString, forKey: "lastUsedBudget")
	}

	func delete(budget id: Budget.ID) {
		let index = budgets.firstIndex { $0.id == id }!
		budgets.remove(at: index)
		save()
	}

	private func save() {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		try! encoder
			.encode(budgets)
			.write(to: saveURL, options: [.atomic, .completeFileProtection])
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
