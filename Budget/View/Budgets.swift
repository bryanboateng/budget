import SwiftUI

struct Budgets: View {
	@EnvironmentObject private var model: Model

	@State private var isManagingCategories = false
	@State private var categoryBeingExtended: Category?
	@State private var isCreatingBudget = false

	private var totalBalance: Decimal {
		model.categories.reduce(0) { partialResult, category in
			partialResult + category.totalBalance
		}
	}

	var body: some View {
		Group {
			if !model.categories.isEmpty {
				List {
					Text("Total Balance")
						.font(.headline)
						.badge(totalBalance.formatted(.eur()))
					ForEach(model.categories, id: \.self) { category in
						Section(
							header:
								HStack {
									Text(category.name)
									Spacer()
									Button {
										categoryBeingExtended = category
									} label: {
										Label("New Budget", systemImage: "plus")
											.labelStyle(.iconOnly)
									}
								}
						) {
							if !category.budgets.isEmpty {
								BudgetList(category: category)
							} else {
								Text("No budgets.")
									.foregroundStyle(.secondary)
									.multilineTextAlignment(.center)
									.frame(maxWidth: .infinity)
							}
						}
						.headerProminence(.increased)
					}
				}
			} else {
				Text("No categories.")
					.foregroundStyle(.secondary)
			}
		}
		.navigationTitle("Budgets")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					isManagingCategories = true
				} label: {
					Label("Categories", systemImage: "folder")
				}
			}
		}
		.sheet(isPresented: $isManagingCategories) {
			CategoryManager(categories: model.categories)
		}
		.sheet(item: $categoryBeingExtended) { category in
			BudgetCreator(category: category)
		}
	}
}
