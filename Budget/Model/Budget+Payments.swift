import Foundation

extension Budget {
    @objc dynamic var payments: Set<Payment> {
        let typedContactPayments = contactPayments as! Set<Payment>
        let typedSendBudgetPayments = sendBudgetPayments as! Set<Payment>
        let typedReceivedBudgetPayments = receivedBudgetPayments as! Set<Payment>
        return typedContactPayments.union(typedSendBudgetPayments.union(typedReceivedBudgetPayments))
    }
}
