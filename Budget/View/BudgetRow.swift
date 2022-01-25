import SwiftUI

struct BudgetRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        if (budget.isFault) {
            EmptyView()
        } else {
            HStack {
                Image(systemName: budget.symbol!)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(budget.color.swiftUIColor)
                    .font(.largeTitle)
                Text(budget.name!)
                    .foregroundColor(.primary)
                    .font(.headline)
                Spacer()
                Text(budget.balance!.decimalValue.formatted(.eur()))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return BudgetRow(budget: budget)
            .previewLayout(.sizeThatFits)
    }
}
