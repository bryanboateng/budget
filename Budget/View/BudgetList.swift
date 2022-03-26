import SwiftUI

struct BudgetList: View {
    @EnvironmentObject private var model: Model
    
    @State private var budgetBeingEdited: Budget?
    @State private var budgetAdjustingBalance: Budget?
    @State private var budgetBeingDeleted: Budget?
    @State private var budgetWhosHistoryIsShown: Budget?
    
    let category: Category
    
    var body: some View {
        ForEach(
            category.budgets.sorted { lhs, rhs in
                if lhs.balance == rhs.balance {
                    return lhs.name < rhs.name
                }
                return lhs.balance > rhs.balance
            }
        ) { budget in
            Menu {
                Button {
                    budgetAdjustingBalance = budget
                } label: {
                    Label("Saldo anpassen", systemImage: "arrow.left.arrow.right")
                }
                
                Button {
                    budgetWhosHistoryIsShown = budget
                } label: {
                    Label("Historie", systemImage: "clock")
                }
                
                Button {
                    budgetBeingEdited = budget
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    budgetBeingDeleted = budget
                } label: {
                    Label("Löschen", systemImage: "trash")
                }
            } label: {
                BudgetRow(budget: budget, color: category.color)
            }
        }
        .sheet(item: $budgetBeingEdited) { budget in
            BudgetEditor(budget: budget, category: category)
        }
        .sheet(item: $budgetAdjustingBalance) { budget in
            BalanceAdjuster(budget: budget, category: category)
        }
        .sheet(item: $budgetWhosHistoryIsShown) { budget in
            BalanceHistory(budget: budget)
        }
        .actionSheet(item: $budgetBeingDeleted) { budget in
            ActionSheet(
                title: Text("\(budget.name) löschen"),
                message: Text("Soll das Budget \(budget.name) wirklich gelöscht werden?"),
                buttons: [
                    .destructive(Text("Budget löschen")) {
                        model.delete(budget, inCategory: category)
                    },
                    .cancel()
                ]
            )
        }
    }
}
