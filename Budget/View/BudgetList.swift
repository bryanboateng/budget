import SwiftUI

struct BudgetList: View {
    private static let spacing: CGFloat = 4

    @FetchRequest(
        entity: Budget.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Budget.balance, ascending: false),
        ]
    ) var budgets: FetchedResults<Budget>
    
    @State private var isCreatingBudget = false
    @State private var budgetBeingEdited: Budget?
    @State private var budgetChangingBalance: Budget?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TotalBalance(
                    amount:
                        budgets.reduce(0, { x, budget  in
                            budget.balance!.adding(x)
                        })
                )
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: BudgetList.spacing) {
                    ForEach(budgets, id: \.id!) { budget in
                        BudgetRow(budget: budget)
                            .contentShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                            .contextMenu {
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
                            }
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Budgets")
        .toolbar {
            Button {
                isCreatingBudget = true
            } label: {
                Label("Neues Budget", systemImage: "plus")
            }
        }
        .sheet(isPresented: $isCreatingBudget) {
            BudgetCreator()
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
