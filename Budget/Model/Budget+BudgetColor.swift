//
//  Budget+BudgetColor.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 02.04.21.
//

import Foundation

extension Budget {
    var color: BudgetColor {
        get { return BudgetColor(rawValue: colorRaw)!}
        set { colorRaw = newValue.rawValue }
    }
}
