import SwiftUI

struct BudgetView: View {
    @State private var isEditing = false
    @State private var directionOfNewPayment: PaymentDirection?
    @ObservedObject var budget: Budget
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            Group {
                if budget.isFault {
                    EmptyView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading){
                            TotalBalance(amount: budget.totalBalance)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            VStack(spacing: 4) {
                                ForEach((budget.payments).sorted { (x, y) in return x.date! < y.date! }, id: \.self) { payment in
                                    switch payment {
                                    case let contactPayment as ContactPayment:
                                        NavigationLink (
                                            destination:
                                                ContactPaymentView(contactPayment: contactPayment)
                                        ){
                                            ContactPaymentRow(contactPayment: contactPayment)
                                        }
                                    case let budgetPayment as BudgetPayment:
                                        if budget.receivedBudgetPayments!.contains(budgetPayment) {
                                            NavigationLink (
                                                destination:
                                                    BudgetPaymentView(budgetPayment: budgetPayment, shownDirection: .incoming)
                                            ){
                                                BudgetPaymentRow(budgetPayment: budgetPayment, shownDirection: .incoming)
                                            }
                                        } else if budget.sendBudgetPayments!.contains(budgetPayment) {
                                            NavigationLink (
                                                destination:
                                                    BudgetPaymentView(budgetPayment: budgetPayment, shownDirection: .outgoing)
                                            ){
                                                BudgetPaymentRow(budgetPayment: budgetPayment, shownDirection: .outgoing)
                                            }
                                        } else {
                                            fatalError()
                                        }
                                    default:
                                        fatalError()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .navigationTitle(budget.name!)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button { isEditing = true } label: {
                                    Image(systemName: "info.circle")
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Menu {
                                    Button { directionOfNewPayment = .outgoing } label: {
                                        Label("Ausgehende Zahlung", systemImage: "arrow.up")
                                    }
                                    Button{ directionOfNewPayment = .incoming } label: {
                                        Label("Eingehende Zahlung", systemImage: "arrow.down")
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .imageScale(.large)
                                }
                            }
                        }
                        .sheet(isPresented: $isEditing) {
                            BudgetEditor(budget: budget)
                        }
                        .sheet(item: $directionOfNewPayment) { direction in
                            PaymentCreator(budget: budget, direction: direction)
                        }
                    }
                }
            }
        }
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        
        let budget = Budget(context: PersistenceController.preview.container.viewContext)
        budget.name = "Lebensmittel"
        budget.color = .pink
        
        return NavigationView {
            BudgetView(budget: budget)
        }
    }
}
