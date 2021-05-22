import SwiftUI

struct PaymentCreator: View {
    @Environment(\.presentationMode) private var presentationMode
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    @State private var paymentParty: PaymentParty?
    @State private var isPickingPaymentParty = false
    @State private var amount: Decimal = 0
    @State private var date = Date()
    @State private var datePickerIsShown = false
    @State private var purpose = ""
    
    @ObservedObject var budget: Budget
    let direction: PaymentDirection
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Aufträger")) {
                    switch direction {
                    case .outgoing:
                        PaymentCreatorBudgetRow(budget: budget)
                    case .incoming:
                        selectPaymentPartyButton
                    }
                }
                
                Section (header: Text("Begünstiger")) {
                    switch direction {
                    case .outgoing:
                        selectPaymentPartyButton
                    case .incoming:
                        PaymentCreatorBudgetRow(budget: budget)
                    }
                }
                
                Section(header: Text("Betrag")) {
                    CurrencyField(amount: $amount)
                }
                
                Section(header: Text("Datum")) {
                    DatePicker(
                        "Zeit",
                        selection: $date,
                        displayedComponents: [.hourAndMinute]
                    )
                    Button {
                        datePickerIsShown.toggle()
                    } label: {
                        HStack {
                            Text("Datum")
                            Spacer()
                            Text("\(date, formatter: Self.dateFormatter)")
                        }
                        .foregroundColor(.primary)
                    }
                    if(datePickerIsShown) {
                        DatePicker(
                            "Datum",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }
                
                Section(header: Text("Verwendungszweck")) {
                    TextEditor(text: $purpose)
                }
                
                Section {
                    doneButton
                }
            }
            .navigationTitle("Neue Zahlung")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    doneButton
                }
            }
            .sheet(isPresented: $isPickingPaymentParty) {
                PaymentPartyPicker(paymentParty: $paymentParty, direction: direction)
            }
        }
    }
    
    var selectPaymentPartyButton: some View {
        Button {
            isPickingPaymentParty = true
        } label: {
            if let paymentParty = paymentParty {
                switch paymentParty {
                case .contact(let contact):
                    Text(contact)
                        .foregroundColor(.primary)
                case .budget(let budget):
                    PaymentCreatorBudgetRow(budget: budget)
                }
            }
        }
    }
    
    var doneButton: some View {
        Button("Fertig") {
            guard let paymentParty = paymentParty else {
                return
            }
            
            switch paymentParty {
            case .budget(let otherBudget):
                let payment = BudgetPayment(context: PersistenceController.shared.container.viewContext)
                payment.amount = NSDecimalNumber(decimal: amount)
                payment.date = date
                payment.purpose = purpose
                switch direction {
                case .incoming:
                    payment.sender = otherBudget
                    payment.receiver = budget
                case .outgoing:
                    payment.sender = budget
                    payment.receiver = otherBudget
                }
            case .contact(let contact):
                let payment = ContactPayment(context: PersistenceController.shared.container.viewContext)
                payment.amount = NSDecimalNumber(decimal: amount)
                payment.date = date
                payment.purpose = purpose
                payment.budget = budget
                payment.direction = direction
                payment.contact = contact
            }
            
            PersistenceController.shared.save()
            
            presentationMode.wrappedValue.dismiss()
        }
        .disabled(purpose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || amount == 0.0 || paymentParty == nil)
    }
}

struct PaymentCreator_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return PaymentCreator(budget: budget, direction: .outgoing)
            .preferredColorScheme(.dark)
    }
}
