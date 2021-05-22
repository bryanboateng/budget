import SwiftUI

struct PaymentCreatorBudgetRow: View {
    let budget: Budget
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 6)
                .foregroundColor(budget.color.swiftUIColor)
            Text(budget.name!)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            Text("\(budget.totalBalance, formatter: NumberFormatter.currency)")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

struct PaymentCreatorBudgetRow_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return PaymentCreatorBudgetRow(budget: budget)
            .previewLayout(.sizeThatFits)
    }
}
