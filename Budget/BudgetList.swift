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
    
    let budgets = [
        Budget(amount: 9.99),
        Budget(amount: 9.98),
        Budget(amount: 9.97),
        Budget(amount: 9.96),
        Budget(amount: 9.95),
        Budget(amount: 9.94)
    ]
    
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
                        BudgetListItem(amount: budget.amount)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Budgets")
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
