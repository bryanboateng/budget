//
//  BudgetCreator.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 21.03.21.
//

import SwiftUI

struct BudgetCreator: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var budgetName = ""
    @State var color = Budget.Color.allCases.randomElement()!
    
    @Binding var budgets: [Budget]
    
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
                        budgets.append(Budget(name: budgetName.trimmingCharacters(in: .whitespaces), color: color))
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
        BudgetCreator(budgets: .constant([Budget(name: "Lebensmittel", color: .blue)]))
    }
}
