//
//  BudgetFace.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 29.01.21.
//

import UIKit

class BudgetFace: UIView {
    
    @IBOutlet weak private var innerCircle: UIView!
    
    var color: UIColor?{
        didSet {
            updateColor()
        }
    }
    
    override func awakeFromNib() {
        layer.cornerRadius = frame.width/2
        innerCircle.layer.cornerRadius = innerCircle.frame.width/2
        color = .secondarySystemFill
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if ((self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle)) {
            updateColor()
        }
    }
    
    private func updateColor() {
        if let color = color {
            if traitCollection.userInterfaceStyle == .light {
                var hue: CGFloat = 0
                var saturation: CGFloat = 0
                var brightness: CGFloat = 0
                var alpha: CGFloat = 0
                _ = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                innerCircle.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness-0.2, alpha: alpha)
            } else {
                innerCircle.backgroundColor = color
            }
            backgroundColor = color.withAlphaComponent(0.35)
        }
    }
}
