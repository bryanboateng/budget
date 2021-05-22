import SwiftUI

struct BudgetCreator: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State var budgetName = ""
    @State var color = BudgetColor.allCases.randomElement()!
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    Circle()
                        .foregroundColor(color.swiftUIColor)
                        .frame(width: 120, height: 120)
                    TextField("Name", text: $budgetName)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    ColorPicker(selectedColor: $color)
                }
                .padding(.top, 60)
                .padding(Edge.Set.all.subtracting(.top))
            }
            .navigationTitle("Neues Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        let budget = Budget(context: managedObjectContext)
                        budget.name = budgetName.trimmingCharacters(in: .whitespaces)
                        budget.color = color
                        PersistenceController.shared.save()
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(budgetName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            
        }
    }
}

struct BudgetCreator_Previews: PreviewProvider {
    static var previews: some View {
        BudgetCreator()
    }
}
