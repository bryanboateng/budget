//
//  BudgetModel.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 25.03.21.
//

import Foundation

class BudgetModel: ObservableObject {
    @Published var budgets: Set<Budget> = [
        Budget(name: "Lebensmittel", color: .orange),
        Budget(name: "Lebensmittel", color: .red),
        Budget(name: "Lebensmittel", color: .green),
        Budget(name: "Lebensmittel", color: .pink),
        Budget(name: "Lebensmittel", color: .yellow),
        Budget(name: "Lebensmittel", color: .blue)
    ]
}
