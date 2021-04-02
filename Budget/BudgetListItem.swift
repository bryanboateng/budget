//
//  Budget.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 20.03.21.
//

import SwiftUI
struct BudgetListItem: View {
    @Environment(\.colorScheme) var colorScheme
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    let budget: Budget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(budget.name!)
                .bold()
                .lineLimit(0)
                .foregroundColor(budget.color.swiftUIColor)
                .brightness(colorScheme == .light ? -0.2 : 0)
            Text("\(budget.totalBalance, formatter: Self.currencyFormatter)")
                .font(.system(.body, design: .rounded))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(budget.color.swiftUIColor.opacity(0.35))
        .cornerRadius(16)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return BudgetListItem(budget: budget)
            .previewLayout(.sizeThatFits)
    }
}
