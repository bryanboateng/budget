//
//  BudgetApp.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 20.03.21.
//

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
