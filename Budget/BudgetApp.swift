import ComposableArchitecture
import SwiftUI

@main
struct BudgetApp: App {
	let accounts: Accounts? = {
		do {
			@Dependency(\.dataManager.load) var loadData
			return try JSONDecoder().decode(
				Accounts?.self,
				from: loadData(.accounts)
			)
		} catch {
			return Accounts?.none
		}
	}()
	var body: some Scene {
		WindowGroup {
			NavigationStack {
				AccountListView(
					store: Store(
						initialState: AccountListFeature.State(
							accounts: accounts,
							destination: {
								if let accounts {
									return .detail(.init(account: accounts.primary))
								} else {
									return nil
								}
							}()
						)
					) {
						AccountListFeature()
							._printChanges()
					}
				)
			}
		}
	}
}
