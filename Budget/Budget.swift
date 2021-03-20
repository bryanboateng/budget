//
//  Budget.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 20.03.21.
//

import SwiftUI
struct Budget: View {
    @Environment(\.colorScheme) var colorScheme
    
    let color: Color = .blue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Groceries")
                .bold()
                .foregroundColor(color)
                .brightness(colorScheme == .light ? -0.2 : 0)
            Text("99,99 €")
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.35))
        .cornerRadius(16)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Budget()
            .previewLayout(.sizeThatFits)
    }
}
