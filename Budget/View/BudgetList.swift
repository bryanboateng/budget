import SwiftUI

struct BudgetList: View {
    @EnvironmentObject private var model: Model
    
    private static let spacing: CGFloat = 4
    
    @State private var isCreatingCategory = false
    @State private var categoryBeingExtended: Category?
    
    @State private var isCreatingBudget = false
    @State private var budgetBeingEdited: Budget?
    @State private var budgetAdjustingBalance: Budget?
    @State private var budgetBeingDeleted: Budget?
    @State private var budgetWhosLastBalanceAdjustmentIsBeingShown: Budget?
    
    private var totalBalance: Decimal {
        model.categories.reduce(0) { partialResult, category in
            partialResult + category.budgets.reduce(0) { partialResult, budget in
                partialResult + budget.balance
            }
        }
    }
    
    var body: some View {
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
                    ForEach(
                        category.budgets.sorted { lhs, rhs in
                            if lhs.balance == rhs.balance {
                                return lhs.name < rhs.name
                            }
                            return lhs.balance < rhs.balance
                        }
                    ) { budget in
                        Menu {
                            Button {
                                budgetAdjustingBalance = budget
                            } label: {
                                Label("Saldo anpassen", systemImage: "arrow.left.arrow.right")
                            }
                            
                            Button {
                                budgetWhosLastBalanceAdjustmentIsBeingShown = budget
                            } label: {
                                Label("Letzte Saldoanpassung", systemImage: "clock")
                            }
                            
                            Button {
                                budgetBeingEdited = budget
                            } label: {
                                Label("Bearbeiten", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                budgetBeingDeleted = budget
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        } label: {
                            HStack {
                                BudgetRow(budget: budget, color: category.color)
                            }
                        }
                    }
                }
                .headerProminence(.increased)
                .sheet(item: $budgetBeingEdited) { budget in
                    BudgetEditor(budget: budget, category: category)
                }
                .sheet(item: $budgetAdjustingBalance) { budget in
                    BalanceAdjuster(budget: budget, category: category)
                }
                .actionSheet(item: $budgetBeingDeleted) { budget in
                    ActionSheet(
                        title: Text("\(budget.name) löschen"),
                        message: Text("Soll das Budget \(budget.name) wirklich gelöscht werden?"),
                        buttons: [
                            .destructive(Text("Budget löschen")) {
                                model.delete(budget, inCategory: category)
                            },
                            .cancel()
                        ]
                    )
                }
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
        .lastBalanceAdjustmentOverlay(budget: $budgetWhosLastBalanceAdjustmentIsBeingShown)
    }
}
