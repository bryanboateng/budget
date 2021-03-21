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
    
    let name: String
    let amount: Double
    let color: Budget.Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .bold()
                .lineLimit(0)
                .foregroundColor(color.swiftUIColor)
                .brightness(colorScheme == .light ? -0.2 : 0)
            Text("\(NSNumber(value: amount), formatter: Self.currencyFormatter)")
                .font(.system(.body, design: .rounded))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.swiftUIColor.opacity(0.35))
        .cornerRadius(16)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetListItem(name: "Lebensmittel", amount: 99.99, color: .yellow)
            .previewLayout(.sizeThatFits)
    }
}
