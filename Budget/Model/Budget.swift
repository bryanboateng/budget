import Foundation

struct Budget: Codable, Identifiable {
    let id: UUID
    var name: String
    var symbol: String
    var balance: Decimal = 0
    var lastBalanceAdjustment: Decimal? = nil
}

extension Budget: Hashable {
    static func == (lhs: Budget, rhs: Budget) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
