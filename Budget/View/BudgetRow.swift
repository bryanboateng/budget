import SwiftUI

struct BudgetRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        if (budget.isFault) {
            EmptyView()
        } else {
            Label {
                Text(budget.name!)
                    .multilineTextAlignment(.leading)
            } icon: {
                Image(systemName: budget.symbol!)
                    .font(.title2)
                    .foregroundColor(budget.category!.color.swiftUIColor)
            }
            .badge(budget.balance!.decimalValue.formatted(.eur()))
            .foregroundColor(.primary)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        
        return BudgetRow(budget: budget)
            .previewLayout(.sizeThatFits)
    }
}
