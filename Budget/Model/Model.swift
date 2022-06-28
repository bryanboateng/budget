import Foundation

@MainActor class Model: ObservableObject {
	@Published private(set) var categories: [Category]

	private let savePath = FileManager.documentsDirectory
		.appendingPathComponent("categories")

	init() {
		do {
			let data = try Data(contentsOf: savePath)
			categories = try JSONDecoder().decode([Category].self, from: data)
		} catch {
			categories = []
		}
	}

	func reorganizeCategories(_ newCategoryInfo: [(id: Category.ID, name: String, color: Category.Color)]) {
		categories = newCategoryInfo.map { categoryInfo  -> Category in
			var category = Category(id: categoryInfo.id, name: categoryInfo.name, color: categoryInfo.color)
			if let existingCategory = categories.first(where: { category in
				category.id == categoryInfo.id
			}) {
				category.budgets = existingCategory.budgets
			}
			return category
		}
		save()
	}

	func insert(_ budget: Budget, into category: Category) {
		var category = self[category.id]
		category.budgets.insert(budget)
		self[category.id] = category
		save()
	}

	func update(_ budget: Budget, of category: Category, withName name: String, andSymbol symbol: String) {
		var budget = self[category.id][budget.id]
		budget.name = name
		budget.symbol = symbol
		self[category.id][budget.id] = budget
		save()
	}

	func adjustBalance(of budget: Budget, of category: Category, by amount: Decimal) {
		var budget = self[category.id][budget.id]
		budget.balanceAdjustments.insert(BalanceAdjustment(date: .now, amount: amount))
		self[category.id][budget.id] = budget
		save()
	}

	func delete(_ budget: Budget, of category: Category) {
		var category = self[category.id]
		category.budgets.remove(budget)
		self[category.id] = category
		save()
	}

	private func save() {
		do {
			let data = try JSONEncoder().encode(categories)
			try data.write(to: savePath, options: [.atomic, .completeFileProtection])
		} catch {
			print("Unable to save data.")
		}
	}

	subscript(categoryID: Category.ID) -> Category {
		get {
			return categories.first(where: { $0.id == categoryID })!
		}

		set(newValue) {
			categories[categories.firstIndex(where: { $0.id == categoryID })!] = newValue
		}
	}
}
