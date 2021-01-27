//
//  TableViewCell.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 27.01.21.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak private var innerVi: UIView!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    
    var title: String? = nil {
        didSet {
            if let title = title {
                titleLabel.text = title
            }
        }
    }
    
    var date: Date? = nil {
        didSet {
            if let date = date {
                let timeFormatter = DateFormatter()
                timeFormatter.timeStyle = .short
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short

                dateLabel.text = "\(timeFormatter.string(from: date)) · \(dateFormatter.string(from: date))"
            }
        }
    }
    
    var price: Double? = nil {
        didSet {
            if let price = price {
                let formatter = NumberFormatter()
                formatter.currencyCode = "EUR"
                formatter.numberStyle = .currency

                priceLabel.text = formatter.string(from: NSNumber(value: price))!
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        innerVi.layer.cornerRadius = 10
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
