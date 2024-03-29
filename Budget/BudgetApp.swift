import ComposableArchitecture
import SwiftUI

@main
struct BudgetApp: App {
	var body: some Scene {
		WindowGroup {
			NavigationStack {
				OverviewView(
					store: Store(
						initialState: OverviewFeature.State()
					) {
						OverviewFeature()
//							._printChanges()
					}
				)
			}
		}
	}
}
