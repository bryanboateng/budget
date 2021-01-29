//
//  BudgetListFlowLayout.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 26.01.21.
//

import UIKit

class BudgetListFlowLayout: UICollectionViewFlowLayout {
    private let spacing: CGFloat = 4
    
    override func prepare() {
        super.prepare()
        
        minimumInteritemSpacing = spacing
        minimumLineSpacing = spacing
        sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
}
