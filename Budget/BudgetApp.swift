import ComposableArchitecture
import SwiftUI

@main
struct BudgetApp: App {
	var body: some Scene {
		WindowGroup {
			NavigationStack {
				AccountListView(
					store: Store(
						initialState: AccountListFeature.State()
					) {
						AccountListFeature()
							._printChanges()
					}
				)
			}
		}
	}
}
