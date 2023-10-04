import SwiftUI

@main
struct BudgetApp: App {
	@StateObject private var model = Model()

	var body: some Scene {
		WindowGroup {
			NavigationStack {
				Overview()
					.environmentObject(model)
			}
		}
	}
}
