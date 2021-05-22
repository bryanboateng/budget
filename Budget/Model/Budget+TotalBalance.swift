import Foundation

extension Budget {
    
    @objc dynamic var totalBalance: NSDecimalNumber {
        let contactPaymentsAmount: NSDecimalNumber = (contactPayments as! Set<ContactPayment>).reduce(0) { x, payment in
            switch payment.direction {
            case .incoming:
                return x.adding(payment.amount!)
            case .outgoing:
                return x.subtracting(payment.amount!)
            }
        }
        
        let sendBudgetPaymentsAmount: NSDecimalNumber = (sendBudgetPayments as! Set<BudgetPayment>).reduce(0) { x, payment in
            return x.subtracting(payment.amount!)
        }
        
        let receivedBudgetPaymentsAmount: NSDecimalNumber = (receivedBudgetPayments as! Set<BudgetPayment>).reduce(0) { x, payment in
            return x.adding(payment.amount!)
        }
        
        return contactPaymentsAmount.adding(sendBudgetPaymentsAmount).adding(receivedBudgetPaymentsAmount)
    }
}
