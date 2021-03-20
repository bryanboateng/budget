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
    
    let amount: Double
    let color: Color = .blue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Groceries")
                .bold()
                .foregroundColor(color)
                .brightness(colorScheme == .light ? -0.2 : 0)
            Text("\(NSNumber(value: amount), formatter: Self.currencyFormatter)")
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.35))
        .cornerRadius(16)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetListItem(amount: 99.99)
            .previewLayout(.sizeThatFits)
    }
}
