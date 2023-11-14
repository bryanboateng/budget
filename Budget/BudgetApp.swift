import ComposableArchitecture
import SwiftUI

@main
struct BudgetApp: App {
	var body: some Scene {
		WindowGroup {
			AppView(
				store: Store(
					initialState: AppFeature.State(
						overview: OverviewFeature.State()
					)
				) {
					AppFeature()
//						._printChanges()
				}
			)
		}
	}
}
