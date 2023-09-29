import SwiftUI

struct Overview: View {
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
			if model.categories.isEmpty {
				ContentUnavailableView {
					Label("Keine Kategorien", systemImage: "folder.fill")
				}
			} else {
				List {
					BalanceDisplay(balance: totalBalance)
					ForEach(model.categories, id: \.self) { category in
						Section(
							header:
								HStack {
									Text(category.name)
									Spacer()
									Button {
										categoryBeingExtended = category
									} label: {
										Label("Neues Budget", systemImage: "plus")
											.labelStyle(.iconOnly)
									}
								}
								.headerProminence(.increased)
						) {
							if !category.budgets.isEmpty {
								CategoryRow(category: category)
									.environmentObject(model)
							} else {
								ContentUnavailableView {
									Label("Keine Budgets", systemImage: "basket.fill")
								}
							}
						}
					}
				}
			}
		}
		.navigationTitle("Konto")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					isManagingCategories = true
				} label: {
					Label("Kategorien", systemImage: "folder")
				}
			}
			ToolbarItemGroup(placement: .bottomBar) {
				Spacer()
				Button("Saldo anpassen", systemImage: "arrow.left.arrow.right") {
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

private struct BalanceDisplay: View {
	let balance: Decimal

	var body: some View {
		VStack(alignment: .leading) {
			Text("Kontostand")
				.foregroundStyle(.secondary)
				.font(.subheadline)
			Text(balance, format: .eur())
				.font(.title)
				.fontWeight(.semibold)
		}
	}
}
