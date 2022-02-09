import Foundation

extension Category {
    var color: CategoryColor {
        get { return CategoryColor(rawValue: colorRaw)!}
        set { colorRaw = newValue.rawValue }
    }
}
