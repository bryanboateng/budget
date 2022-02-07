import SwiftUI

struct BudgetList: View {
    private static let spacing: CGFloat = 4
    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.name, ascending: true),
        ]
    ) var categories: FetchedResults<Category>
    
    // The following is only used to capture department relationship changes
    @FetchRequest(
        entity: Budget.entity(),
        sortDescriptors: [
        ]
    ) var budgets: FetchedResults<Budget>
    
    @State private var isCreatingCategory = false
    @State private var categoryBeingExtended: Category?
    
    @State private var isCreatingBudget = false
    @State private var budgetBeingEdited: Budget?
    @State private var budgetAdjustingBalance: Budget?
    @State private var budgetBeingDeleted: Budget?
    @State private var budgetWhosLastBalanceAdjustmentIsBeingShown: Budget?
    
    private var totalBalance: NSDecimalNumber {
        return categories.reduce(0, { partialResult, category in
            (category.budgets! as! Set<Budget>).reduce(0, { partialResult, budget in
                budget.balance!.adding(partialResult)
            }).adding(partialResult)
        })
    }
    
    var body: some View {
        List {
            Text("Gesamter Stand")
                .font(.headline)
                .badge(totalBalance.decimalValue.formatted(.eur()))
            ForEach(categories, id: \.id!) { category in
                Section(
                    header:
                        HStack {
                            Text(category.name!)
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
                        (category.budgets! as! Set<Budget>).sorted { lhs, rhs in
                            let balanceComparisonResult = lhs.balance!.compare(rhs.balance!)
                            if balanceComparisonResult == .orderedSame {
                                return lhs.name! < rhs.name!
                            }
                            return lhs.balance!.compare(rhs.balance!) == .orderedDescending
                        }, id: \Budget.id!
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
                                BudgetRow(budget: budget)
                            }
                        }
                    }
                }
                .headerProminence(.increased)
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
        .sheet(item: $budgetBeingEdited) { budget in
            BudgetEditor(budget: budget)
        }
        .sheet(item: $budgetAdjustingBalance) { budget in
            BalanceAdjuster(
                budget: budget,
                // !!!: Required: pass some dependency on employees to trigger view updates
                budgetCount: budgets.count
            )
        }
        .actionSheet(item: $budgetBeingDeleted) { budget in
            ActionSheet(
                title: Text("\(budget.name!) löschen"),
                message: Text("Soll das Budget \(budget.name!) wirklich gelöscht werden?"),
                buttons: [
                    .destructive(Text("Budget löschen")) {
                        PersistenceController.shared.container.viewContext.delete(budget)
                        PersistenceController.shared.save()
                    },
                    .cancel()
                ]
            )
        }
        .lastBalanceAdjustmentOverlay(budget: $budgetWhosLastBalanceAdjustmentIsBeingShown)
    }
}

struct BudgetList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                BudgetList()
            }
            NavigationView {
                BudgetList()
            }
            .preferredColorScheme(.dark)
        }
    }
}
