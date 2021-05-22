import Foundation

extension Budget {
    
    @objc dynamic var totalBalance: NSDecimalNumber {
        return (payments as! Set<Payment>).reduce(0) { x, payment in
            payment.amount!.adding(x)
        }
    }
}
