import SwiftUI

@main
struct BudgetApp: App {
    @StateObject private var model = Model()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                BudgetList()
                    .environmentObject(model)
            }
        }
    }
}
