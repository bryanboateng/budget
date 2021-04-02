//
//  BudgetView.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 21.03.21.
//

import SwiftUI

struct BudgetView: View {
    let budget: Budget
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TotalBalance(amount: budget.totalBalance)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 4) {
                    ForEach((budget.payments as! Set<Payment>).sorted { (x, y) in return x.date! < y.date! }, id: \.self) { payment in
                        PaymentRow(payment: payment)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle(budget.name!)
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return NavigationView {
            BudgetView(budget: budget)
        }
    }
}
