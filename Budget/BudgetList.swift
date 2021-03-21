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
        Budget(name: "Lebensmittel", amount: 9.99, color: .orange),
        Budget(name: "Lebensmittel", amount: 9.98, color: .red),
        Budget(name: "Lebensmittel", amount: 9.97, color: .green),
        Budget(name: "Lebensmittel", amount: 9.96, color: .pink),
        Budget(name: "Lebensmittel", amount: 9.95, color: .yellow),
        Budget(name: "Lebensmittel", amount: 9.94, color: .blue)
    ]
    @State private var isCreatingBudget = false

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TotalBalance(
                    amount:
                        budgets.reduce(0, { x, budget  in
                            x + budget.amount
                        })
                )
                LazyVGrid(columns: columns, spacing: BudgetList.spacing) {
                    ForEach(budgets, id: \.self) { budget in
                        BudgetListItem(name: budget.name, amount: budget.amount, color: budget.color)
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
