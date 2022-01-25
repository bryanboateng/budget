import SwiftUI

struct BudgetEditor: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var budgetName = ""
    @State private var color = BudgetColor.green
    @State private var isAskingForDeletionConformation = false
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        if budget.isFault {
            EmptyView()
        } else {
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
                        Button("Budget löschen", role: .destructive) {
                            isAskingForDeletionConformation = true
                        }
                    }
                    .padding(.top, 60)
                    .padding(Edge.Set.all.subtracting(.top))
                }
                .navigationTitle("Budget bearbeiten")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fertig") {
                            budget.name = budgetName.trimmingCharacters(in: .whitespaces)
                            budget.color = color
                            PersistenceController.shared.save()
                            
                            dismiss()
                        }
                        .disabled(budgetName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .onAppear {
                    budgetName = budget.name!
                    color = budget.color
                }
                .actionSheet(isPresented: $isAskingForDeletionConformation) {
                    ActionSheet(
                        title: Text("\(budget.name!) löschen"),
                        message: Text("Soll das Budget \(budget.name!) wirklich gelöscht werden?"),
                        buttons: [
                            .destructive(Text("Budget löschen")) {
                                PersistenceController.shared.container.viewContext.delete(budget)
                                PersistenceController.shared.save()
                                dismiss()
                            },
                            .cancel()
                        ]
                    )
                }
            }
        }
    }
}

struct BudgetEditor_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return BudgetEditor(budget: budget)
    }
}
