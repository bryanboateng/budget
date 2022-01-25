import SwiftUI

struct BudgetList: View {
    private static let spacing: CGFloat = 4
    
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.name, ascending: true),
        ]
    ) var categories: FetchedResults<Category>
    
    @State private var isCreatingCategory = false
    @State private var categoryBeingExtended: Category?
    
    @State private var isCreatingBudget = false
    @State private var budgetBeingEdited: Budget?
    @State private var budgetChangingBalance: Budget?
    
    private var totalBalance: NSDecimalNumber {
        return categories.reduce(0, { partialResult, category in
            (category.budgets! as! Set<Budget>).reduce(0, { partialResult, budget in
                budget.balance!.adding(partialResult)
            }).adding(partialResult)
        })
    }
    
    var body: some View {
        List {
            HStack {
                Text("Gesamter Stand")
                    .foregroundColor(.primary)
                    .font(.headline)
                Spacer()
                Text(totalBalance.decimalValue.formatted(.eur()))
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
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
                            lhs.balance!.compare(rhs.balance!) == .orderedDescending
                        }, id: \Budget.id!
                    ) { budget in
                        Menu {
                            Button {
                                budgetChangingBalance = budget
                            } label: {
                                Label("Bewegen", systemImage: "arrow.left.arrow.right")
                            }
                            
                            Button {
                                budgetBeingEdited = budget
                            } label: {
                                Label("Bearbeiten", systemImage: "pencil")
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
        .sheet(item: $budgetChangingBalance) { budget in
            BalanceChanger(budget: budget)
        }
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
