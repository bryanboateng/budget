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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TotalBalance(amount: 9.99)
                LazyVGrid(columns: columns, spacing: BudgetList.spacing) {
                    ForEach((0..<100)) {_ in
                        Budget(amount: 99.99)
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
