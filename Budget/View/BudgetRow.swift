import SwiftUI

struct BudgetRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        if (budget.isFault) {
            EmptyView()
        } else {
            HStack {
                Label {
                    Text(budget.name!)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                        .font(.headline)
                } icon: {
                    Image(systemName: budget.symbol!)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(budget.color.swiftUIColor)
                        .font(.largeTitle)
                }
                Spacer()
                Text(budget.balance!.decimalValue.formatted(.eur()))
                    .foregroundColor(.primary)
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(nil)
                    .multilineTextAlignment(.trailing)
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
