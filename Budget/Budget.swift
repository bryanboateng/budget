//
//  Budget.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 21.03.21.
//

import SwiftUI

struct Budget: Hashable {
    let name: String
    let amount: Double
    let color: Color
    
    enum Color: CaseIterable {
        case red
        case orange
        case yellow
        case green
        case teal
        case blue
        case purple
        case pink
        
        var swiftUIColor: SwiftUI.Color {
            switch self {
            case .red:
                return SwiftUI.Color.red
            case .orange:
                return SwiftUI.Color.orange
            case .yellow:
                return SwiftUI.Color.yellow
            case .green:
                return SwiftUI.Color.green
            case .teal:
                return SwiftUI.Color(UIColor.systemTeal)
            case .blue:
                return SwiftUI.Color.blue
            case .purple:
                return SwiftUI.Color.purple
            case .pink:
                return SwiftUI.Color("pink")
            }
        }
    }
}
