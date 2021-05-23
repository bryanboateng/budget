import SwiftUI

struct PaymentViewBudgetRow: View {
    let budget: Budget
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 6)
                .foregroundColor(budget.color.swiftUIColor)
            Text(budget.name!)
                .foregroundColor(.primary)
        }
    }
}

struct PaymentViewBudgetRow_Previews: PreviewProvider {
    static var previews: some View {
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return PaymentViewBudgetRow(budget: budget)
            .previewLayout(.sizeThatFits)
    }
}
