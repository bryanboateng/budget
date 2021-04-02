//
//  Budget+TotalBalance.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 01.04.21.
//

import Foundation

extension Budget {
    
    @objc dynamic var totalBalance: NSDecimalNumber {
        return (payments as! Set<Payment>).reduce(0) { x, payment in
            payment.amount!.adding(x)
        }
    }
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case "totalBalance":
            return keyPaths.union(Set(["payments"]))
        default:
            return keyPaths
        }
    }
}
