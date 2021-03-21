//
//  Payment.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 21.03.21.
//

import Foundation

struct Payment: Hashable {
    let party: String
    let purpose: String
    let amount: Double
    let date: Date
}
