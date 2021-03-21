//
//  BudgetList.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 20.03.21.
//

import SwiftUI

struct BudgetList: View {
    private static let spacing: CGFloat = 4
    
    let columns = [
        GridItem(.flexible(), spacing: spacing),
        GridItem(.flexible(), spacing: spacing)
    ]
    
    @State private var budgets = [
        Budget(name: "Lebensmittel", color: .orange),
        Budget(name: "Lebensmittel", color: .red),
        Budget(name: "Lebensmittel", color: .green),
        Budget(name: "Lebensmittel", color: .pink),
        Budget(name: "Lebensmittel", color: .yellow),
        Budget(name: "Lebensmittel", color: .blue)
    ]
    @State private var isCreatingBudget = false

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TotalBalance(
                    amount:
                        budgets.reduce(0, { x, budget  in
                            x + budget.totalBalance
                        })
                )
                LazyVGrid(columns: columns, spacing: BudgetList.spacing) {
                    ForEach(budgets, id: \.self) { budget in
                        NavigationLink(destination: BudgetView(budget: budget)){
                            BudgetListItem(name: budget.name, amount: budget.totalBalance, color: budget.color)
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
            BudgetCreator(budgets: $budgets)
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
