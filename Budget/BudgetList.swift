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
    
    @EnvironmentObject private var model: BudgetModel
    @State private var isCreatingBudget = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TotalBalance(
                    amount:
                        model.budgets.reduce(0, { x, budget  in
                            x + budget.totalBalance
                        })
                )
                LazyVGrid(columns: columns, spacing: BudgetList.spacing) {
                    ForEach(model.budgets.sorted { (lhs, rhs) in return lhs.name < rhs.name }, id: \.self) { budget in
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
