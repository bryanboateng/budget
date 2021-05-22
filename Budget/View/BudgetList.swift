import SwiftUI

struct BudgetList: View {
    private static let spacing: CGFloat = 4
    
    let columns = [
        GridItem(.flexible(), spacing: spacing),
        GridItem(.flexible(), spacing: spacing)
    ]
    
    @FetchRequest(
        entity: Budget.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Budget.name, ascending: true),
        ]
    ) var budgets: FetchedResults<Budget>
    
    @State private var isCreatingBudget = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TotalBalance(
                    amount:
                        budgets.reduce(0, { x, budget  in
                            budget.totalBalance.adding(x)
                        })
                )
                LazyVGrid(columns: columns, spacing: BudgetList.spacing) {
                    ForEach(budgets, id: \.self) { budget in
                        NavigationLink(destination: BudgetView(budget: budget)){
                            BudgetListItem(budget: budget)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Budgets")
        .toolbar {
            Button(action: { isCreatingBudget = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $isCreatingBudget) {
            BudgetCreator()
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
