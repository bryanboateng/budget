import SwiftUI

enum BudgetColor: Int16, CaseIterable  {
    case red = 1
    case orange = 2
    case yellow = 3
    case green = 4
    case teal = 5
    case blue = 6
    case purple = 7
    case pink = 8
    
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
