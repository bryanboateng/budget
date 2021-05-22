import Foundation

extension Budget {
    var color: BudgetColor {
        get { return BudgetColor(rawValue: colorRaw)!}
        set { colorRaw = newValue.rawValue }
    }
}
