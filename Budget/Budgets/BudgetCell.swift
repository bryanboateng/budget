//
//  BudgetCell.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 28.01.21.
//

import UIKit

class BudgetCell: UICollectionViewCell {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var balanceLabel: UILabel!
    
    var title: String? {
        didSet {
            if let title = title {
                titleLabel.text = title
            }
        }
    }
    
    var color: Color? {
        didSet {
            if let color = color {
                backgroundColor = color.uiColor.withAlphaComponent(0.35)
                updateTitleColor()
            }
        }
    }
    
    var balance: Double? {
        didSet {
            if let balance = balance {
                let formatter = NumberFormatter()
                formatter.currencyCode = "EUR"
                formatter.numberStyle = .currency
                
                balanceLabel.text = formatter.string(from: NSNumber(value: balance))!
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10

        let descriptor = titleLabel.font.fontDescriptor.withSymbolicTraits(.traitBold)
        titleLabel.font = UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if ((self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle)) {
            updateTitleColor()
        }
    }
    
    private func updateTitleColor() {
        if traitCollection.userInterfaceStyle == .light {
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            _ = color?.uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            titleLabel.textColor = UIColor(hue: hue, saturation: saturation, brightness: brightness-0.2, alpha: alpha)
        } else {
            titleLabel.textColor = color?.uiColor
        }
    }
}
