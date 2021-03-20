//
//  TotalBalance.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 20.03.21.
//

import SwiftUI

struct TotalBalance: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("1.204,63 €")
                .bold()
                .font(.system(.title2, design: .rounded))
            Text("Gesamter Stand")
                .foregroundColor(.secondary)
        }
    }
}

struct TotalBalance_Previews: PreviewProvider {
    static var previews: some View {
        TotalBalance()
    }
}
