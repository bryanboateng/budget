import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
	@ObservableState
	struct State {
		var overview = OverviewFeature.State()
		var path = StackState<Path.State>()
	}
	enum Action {
		case overview(OverviewFeature.Action)
		case path(StackAction<Path.State, Path.Action>)
	}
	@Reducer
	enum Path {
		case detail(BudgetDetailFeature)
	}

	@Dependency(\.continuousClock) var clock
	@Dependency(\.dataManager.save) var saveData

	var body: some ReducerOf<Self> {
		Scope(state: \.overview, action: \.overview) {
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
		.forEach(\.path, action: \.path)

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
	@Bindable var store: StoreOf<AppFeature>

	var body: some View {
		NavigationStack(path: self.$store.scope(state: \.path, action: \.path)) {
			OverviewView(
				store: self.store.scope(
					state: \.overview,
					action: \.overview
				)
			)
		} destination: { store in
			switch store.case {
			case let .detail(store):
				BudgetDetailView(store: store)
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
