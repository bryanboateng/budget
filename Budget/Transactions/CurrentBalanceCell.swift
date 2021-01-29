//
//  CurrentBalanceCell.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 28.01.21.
//

import UIKit

class CurrentBalanceCell: UITableViewCell {
    
    @IBOutlet weak private var currentBalanceLabel: UILabel!
    
    var price: Double? = nil {
        didSet {
            if let price = price {
                let formatter = NumberFormatter()
                formatter.currencyCode = "EUR"
                formatter.numberStyle = .currency
                
                currentBalanceLabel.text = formatter.string(from: NSNumber(value: price))!
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let descriptor = currentBalanceLabel.font.fontDescriptor.withSymbolicTraits(.traitBold)
        currentBalanceLabel.font = UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
