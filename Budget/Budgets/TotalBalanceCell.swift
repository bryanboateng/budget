//
//  TotalBalanceCell.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 09.02.21.
//

import UIKit

class TotalBalanceCell: UICollectionViewCell {
    
    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    var balance: Double? = nil {
        didSet {
            if let balance = balance {
                let formatter = NumberFormatter()
                formatter.currencyCode = "EUR"
                formatter.numberStyle = .currency
                
                totalBalanceLabel.text = formatter.string(from: NSNumber(value: balance))!
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let descriptor = totalBalanceLabel.font.fontDescriptor.withSymbolicTraits(.traitBold)
        totalBalanceLabel.font = UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
}
