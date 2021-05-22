extension ContactPayment {
    var direction: PaymentDirection {
        get { return PaymentDirection(rawValue: directionRaw)!}
        set { directionRaw = newValue.rawValue }
    }
}
