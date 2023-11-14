import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
	struct State {
		var overview = OverviewFeature.State()
		var path = StackState<Path.State>()
	}
	enum Action {
		case overview(OverviewFeature.Action)
		case path(StackAction<Path.State, Path.Action>)
	}

	struct Path: Reducer {
		enum State {
			case detail(BudgetDetailFeature.State)
		}
		enum Action {
			case detail(BudgetDetailFeature.Action)
		}
		var body: some ReducerOf<Self> {
			Scope(state: /State.detail, action: /Action.detail) {
				BudgetDetailFeature()
			}
		}
	}

	@Dependency(\.continuousClock) var clock
	@Dependency(\.dataManager.save) var saveData

	var body: some ReducerOf<Self> {
		Scope(state: \.overview, action: /Action.overview) {
			OverviewFeature()
		}

		Reduce { state, action in
			switch action {
			case .overview:
				return .none
			case let .path(.element(id: _, action: .detail(.delegate(action)))):
				switch action {
				case let .budgetUpdated(budget):
					state.overview.budgets[id: budget.id] = budget
				case let .deleteStandup(id: id):
					state.overview.budgets.remove(id: id)
					return .none
				}
				return .none
			case .path:
				return .none
			}
		}
		.forEach(\.path, action: /Action.path) {
			Path()
		}

		Reduce { state, _ in
				.run { [budgets = state.overview.budgets] _ in
					enum CancelID { case saveDebounce }
					try await withTaskCancellation(
						id: CancelID.saveDebounce, cancelInFlight: true
					) {
						try await self.clock.sleep(for: .seconds(1))
						try self.saveData(
							JSONEncoder().encode(budgets),
							.budgets
						)
					}
				}
		}
	}
}

struct AppView: View {
	let store: StoreOf<AppFeature>

	var body: some View {
		NavigationStackStore(
			self.store.scope(state: \.path, action: { .path($0) })
		) {
			OverviewView(
				store: self.store.scope(
					state: \.overview,
					action: { .overview($0) }
				)
			)
		} destination: { state in
			switch state {
			case .detail:
				CaseLet(
					/AppFeature.Path.State.detail,
					 action: AppFeature.Path.Action.detail,
					 then: BudgetDetailView.init(store:)
				)
			}
		}
	}
}

#Preview {
	AppView(
		store: Store(
			initialState: AppFeature.State()
		) {
			AppFeature()
		} withDependencies: {
			$0.dataManager = .mock(
				initialData: try? JSONEncoder().encode([Budget.mock])
			)
		}
	)
}
