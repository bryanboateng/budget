import Foundation

struct Budget: Codable, Identifiable {
    let id: UUID
    var name: String
    var symbol: String
    var balanceAdjustments: Set<BalanceAdjustment> = []
    
    init(name: String, symbol: String) {
        self.id = UUID()
        self.name = name
        self.symbol = symbol
    }
    
    var balance: Decimal {
        balanceAdjustments.reduce(0) { partialResult, balanceAdjustment in
            partialResult + balanceAdjustment.amount
        }
    }
}

extension Budget: Hashable {
    static func == (lhs: Budget, rhs: Budget) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
