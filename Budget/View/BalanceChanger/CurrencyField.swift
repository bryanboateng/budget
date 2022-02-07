import SwiftUI

struct CurrencyField: UIViewRepresentable {
    @Binding var amount: Decimal
    let fontSize: CGFloat
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIKitCurrencyField {
        let currencyField = UIKitCurrencyField()
        currencyField.delegate = context.coordinator
        currencyField.textAlignment = .center
        
        currencyField.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        currencyField.adjustsFontSizeToFitWidth = true
        currencyField.numberOfLines = 2
        currencyField.minimumScaleFactor = 0.5
        currencyField.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        currencyField.addGestureRecognizer(tapGesture)
        
        currencyField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        currencyField.setContentHuggingPriority(.required, for: .horizontal)
        
        return currencyField
    }
    
    func updateUIView(_ currencyField: UIKitCurrencyField, context: Context) {
        currencyField.amount = amount
    }
    
    class Coordinator: NSObject, UIKitCurrencyFieldDelegate {
        private var parent: CurrencyField
        
        init(_ parent: CurrencyField) {
            self.parent = parent
        }
        
        func didChangeAmount(amount: Decimal, currencyField: UIKitCurrencyField) {
            parent.amount = amount
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            sender.view?.becomeFirstResponder()
        }
    }
}

protocol UIKitCurrencyFieldDelegate {
    func didChangeAmount(amount: Decimal, currencyField: UIKitCurrencyField)
}

class UIKitCurrencyField: UILabel, UIKeyInput {
    var delegate: UIKitCurrencyFieldDelegate?
    
    var amount: Decimal = 0.0 {
        didSet(oldAmount) {
            let amountString = String(Int(truncating: NSDecimalNumber(decimal:(amount * 100))))
            
            if self.amountString != amountString {
                self.amountString = amountString
            }
            
            if amount != oldAmount {
                delegate?.didChangeAmount(amount: amount, currencyField: self)
            }
        }
    }
    
    private var amountString = "" {
        didSet(oldAmountString) {
            if amountString == "" {
                amountString = "0"
            }
            
            if let amount = Decimal(string: amountString) {
                self.amount = amount / 100
            } else {
                amountString = oldAmountString
            }
            updateText()
        }
    }
    
    var keyboardType: UIKeyboardType = .numberPad
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    var hasText: Bool {
        amountString.isEmpty == false
    }
    
    func insertText(_ text: String) {
        amountString += text
    }
    
    func deleteBackward() {
        _ = amountString.popLast()
    }
    
    func updateText() {
        text = amount.formatted(.eur())
    }
}
