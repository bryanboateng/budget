import SwiftUI

struct Budgets: View {
    @EnvironmentObject private var model: Model
    
    @State private var isCreatingCategory = false
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
                    Text("Gesamter Stand")
                        .font(.headline)
                        .badge(totalBalance.formatted(.eur()))
                    ForEach(model.categories) { category in
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
                        ) {
                            Group {
                                if !category.budgets.isEmpty {
                                    BudgetList(category: category)
                                } else {
                                    Text("In dieser Kategorie gibt es keine Budgets.")
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .headerProminence(.increased)
                    }
                }
            } else {
                Text("Keine Kategorien.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Budgets")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isCreatingCategory = true
                } label: {
                    Label("Neue Kategorie", systemImage: "folder.badge.plus")
                }
            }
        }
        .sheet(isPresented: $isCreatingCategory) {
            CategoryCreator()
        }
        .sheet(item: $categoryBeingExtended) { category in
            BudgetCreator(category: category)
        }
    }
}
