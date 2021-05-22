import SwiftUI
import CoreData

struct PaymentPartyPicker: View {
    @Environment(\.presentationMode) private var presentationMode

    private var contacts: [String] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "ContactPayment")
        fetchRequest.propertiesToFetch = ["contact"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "contact", ascending: true)]
        
        let dictionaries = try! context.fetch(fetchRequest)
        return dictionaries.map { dictionary in
            dictionary.value(forKey: "contact") as! String
        }
    }
    
    @State private var isCreatingContact = false
    
    @Binding var paymentParty: PaymentParty?
    let direction: PaymentDirection
    
    var body: some View {
        NavigationView {
            Form {
                NavigationLink(
                    destination:
                        PaymentPartyPickerBudgetsList(paymentParty: $paymentParty)
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext),
                    label: {
                        Label("Budgets", systemImage: "tray.2")
                    }
                )
                Section(header: Text("Neuer Kontakt")) {
                    Button {
                        isCreatingContact = true
                    } label: {
                        Label {
                            Text("Neuer Kontakt")
                                .foregroundColor(Color.primary)
                        } icon: {
                            Image(systemName: "person.crop.circle.badge.plus")
                        }
                    }
                }
                Section(header: Text("Kontakte")) {
                    ForEach(contacts, id: \.self) { contact in
                        Button(contact) {
                            paymentParty = .contact(contact)
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .onChange(of: paymentParty) { _ in
                presentationMode.wrappedValue.dismiss()
            }
            .sheet(isPresented: $isCreatingContact) {
                ContactCreator(paymentParty: $paymentParty)
            }
            .navigationTitle(direction == .incoming ? "Aufträger" : "Begünstiger")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct PaymentPartyPicker_Previews: PreviewProvider {
    static var previews: some View {
        PaymentPartyPicker(paymentParty: .constant(nil), direction: .outgoing)
    }
}
