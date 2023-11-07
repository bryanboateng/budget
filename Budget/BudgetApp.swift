import ComposableArchitecture
import SwiftUI

@main
struct CounterApp: App {
	var body: some Scene {
		WindowGroup {
			NavigationStack {
				OverviewView(
					store: Store(
						initialState: OverviewFeature.State()
					) {
						OverviewFeature()
					}
				)
			}
		}
	}
}
