//
//  BudgetFace.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 29.01.21.
//

import UIKit

class BudgetFace: UIView {
    
    var color: UIColor?{
        didSet {
            if let color = color {
                backgroundColor = color
            } else {
                backgroundColor = .systemFill
            }
        }
    }
    
    override func awakeFromNib() {
        layer.cornerRadius = frame.width/2
        color = nil
    }
}
