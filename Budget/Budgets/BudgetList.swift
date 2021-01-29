//
//  BudgetList.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 28.01.21.
//

import UIKit

class BudgetList: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let budgets = [
        Budget(title: "Groceries", color: Color(uiColor: .blue), transactions: [
            Transaction(title: "Convini", price: 9.99, date: Date()),
        ]),
        Budget(title: "Groceries", color: Color(uiColor: .blue), transactions: [
            Transaction(title: "Convini", price: 9.99, date: Date()),
        ]),
        Budget(title: "Groceries", color: Color(uiColor: .blue), transactions: [
            Transaction(title: "Convini", price: 9.99, date: Date()),
        ]),
        Budget(title: "Groceries", color: Color(uiColor: .blue), transactions: [
            Transaction(title: "Convini", price: 9.99, date: Date()),
        ]),
        Budget(title: "Groceries", color: Color(uiColor: .blue), transactions: [
            Transaction(title: "Convini", price: 9.99, date: Date()),
        ]),
        Budget(title: "Groceries", color: Color(uiColor: .blue), transactions: [
            Transaction(title: "Convini", price: 9.99, date: Date()),
        ]),
        Budget(title: "Groceries", color: Color(uiColor: .blue), transactions: [
            Transaction(title: "Convini", price: 9.99, date: Date()),
        ]),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TransactionList {
            if let indexPath = self.collectionView.indexPathsForSelectedItems!.last {
                destination.transactions = budgets[indexPath.row].transactions
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return budgets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "budget", for: indexPath) as! BudgetCell
        let budget = budgets[indexPath.row]
        cell.title = budget.title
        cell.color = budget.color
        cell.balance = budget.transactions.reduce(0) { (result, transaction) in
            return result + transaction.price
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInset = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
        let referenceWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width
            - sectionInset.left
            - sectionInset.right
            - collectionView.contentInset.left
            - collectionView.contentInset.right
            - (collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing
        return CGSize(width: referenceWidth/2, height: 100)
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
}
