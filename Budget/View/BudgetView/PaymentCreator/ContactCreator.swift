import SwiftUI

struct ContactCreator: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var contact = ""

    @Binding var paymentParty: PaymentParty?
    
    var contactCanBeSaved: Bool {
        return !contact.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $contact, onCommit:  {
                    if contactCanBeSaved {
                        paymentParty = .contact(contact.trimmingCharacters(in: .whitespaces))
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        paymentParty = .contact(contact.trimmingCharacters(in: .whitespaces))
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(!contactCanBeSaved)
                }
            }
            .navigationTitle("Neuer Kontakt")
        }
    }
}

struct Teleport_Previews: PreviewProvider {
    static var previews: some View {
        ContactCreator(paymentParty: .constant(nil))
    }
}
