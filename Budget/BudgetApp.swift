import SwiftUI

@main
struct BudgetApp: App {
    @StateObject private var model = Model()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Budgets()
                    .environmentObject(model)
            }
        }
    }
}
