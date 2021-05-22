enum PaymentDirection: Int16, Identifiable  {
    var id: Self { self }
    
    case incoming = 1
    case outgoing = 2
}
