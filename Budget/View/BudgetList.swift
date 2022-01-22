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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TotalBalance(
                    amount:
                        categories.reduce(0, { partialResult, category in
                            (category.budgets! as! Set<Budget>).reduce(0, { partialResult, budget in
                                budget.balance!.adding(partialResult)
                            }).adding(partialResult)
                        })
                )
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(categories, id: \.id!) { category in
                    HStack {
                        Text(category.name!)
                            .bold()
                        Spacer()
                        Button {
                            categoryBeingExtended = category
                        } label: {
                            Label("Neues Budget", systemImage: "plus")
                                .labelStyle(.iconOnly)
                        }
                    }
                    .font(.title3)
                    .padding(.vertical, 4)
                    
                    Group {
                        if category.budgets!.count == 0 {
                            Text("In dieser Kategorie gibt es keine Budgets.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
                        } else {
                            VStack(spacing: BudgetList.spacing) {
                                ForEach(
                                    (category.budgets! as! Set<Budget>).sorted { lhs, rhs in
                                        lhs.balance!.compare(rhs.balance!) == .orderedAscending
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
                                        BudgetRow(budget: budget)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.horizontal)
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
