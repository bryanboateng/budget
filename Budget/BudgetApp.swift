import SwiftUI

@main
struct BudgetApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                BudgetList()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
