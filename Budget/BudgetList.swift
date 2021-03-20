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
    
    let budgetCount = 20
    let budgetAmount = 99.99
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TotalBalance(amount: budgetAmount * Double(budgetCount))
                LazyVGrid(columns: columns, spacing: BudgetList.spacing) {
                    ForEach((0..<budgetCount)) {_ in
                        Budget(amount: budgetAmount)
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
