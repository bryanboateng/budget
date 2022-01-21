import SwiftUI
struct BudgetRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var budget: Budget
    
    var body: some View {
        if (budget.isFault) {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Text(budget.name!)
                    .bold()
                    .lineLimit(1)
                    .foregroundColor(budget.color.swiftUIColor)
                    .brightness(colorScheme == .light ? -0.2 : 0)
                Text(budget.balance!.decimalValue.formatted(.eur()))
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.primary) // !!!: Should not be used but .buttonStyle(PlainButtonStyle()) is not working currently
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(budget.color.swiftUIColor.opacity(0.35))
            .cornerRadius(16)
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
