//
//  TableViewController.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 27.01.21.
//

import UIKit

class TableViewController: UITableViewController {
    
    var transactions: [Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count+1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currentBalance", for: indexPath) as! CurrentBalanceCell
            cell.price = transactions.reduce(0) { (result, transaction) in
                return result + transaction.price
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TransactionCell
            let transaction = transactions[indexPath.row-1]
            cell.title = transaction.title
            cell.price = transaction.price
            cell.date = transaction.date
            return cell
        }        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {  (action, sourceView, actionPerformed) in
            let deleteAlertAction = UIAlertAction(title: "Transaktion löschen", style: .destructive) { (action) in
                self.transactions.remove(at: indexPath.row-1)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                actionPerformed(true)
            }
            
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (action) in
                actionPerformed(true)
            }
            
            let alert = UIAlertController(
                title: nil,
                message: "Diese Transaktion wird endgültig gelöscht. Der Vorgang kann nicht widerrufen werden.",
                preferredStyle: .actionSheet)
            alert.addAction(deleteAlertAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
