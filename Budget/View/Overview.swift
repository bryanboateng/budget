import ComposableArchitecture
import OrderedCollections
import SwiftUI

struct OverviewFeature: Reducer {
	struct State: Equatable {
		var budgets: IdentifiedArrayOf<Budget> = []

		var groupedBudgets: OrderedDictionary<Budget.Color, [Budget]> {
			func comparisonValue(_ budget: Budget) -> Decimal {
				if let projection = budget.projection {
					return projection.discretionaryFunds
				} else {
					return budget.balance
				}
			}

			let hello = Dictionary(grouping: budgets) { budget in
				budget.color
			}
				.mapValues { budgets in
					budgets.sorted { lhs, rhs in
						if comparisonValue(lhs) == comparisonValue(rhs) {
							return lhs.name < rhs.name
						}
						return comparisonValue(lhs) > comparisonValue(rhs)
					}
				}

			return OrderedDictionary(
				Budget.Color.allCases.compactMap { color in
					hello[color].map { budgets in
						(color, budgets)
					}
				},
				uniquingKeysWith: { (first, _) in first }
			)
		}

		var totalBalance: Decimal {
			budgets.reduce(0) { partialResult, budget in
				partialResult + budget.balance
			}
		}
	}
	enum Action {
		case historyButtonTapped
		case balanceOperationButtonTapped
		case createBudgetButtonTapped
	}
	@Dependency(\.uuid) var uuid
	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .historyButtonTapped:
				return .none
			case .balanceOperationButtonTapped:
				return .none
			case .createBudgetButtonTapped:
				state.budgets.append(
					Budget(
						id: self.uuid(),
						name: "d",
						symbol: "car",
						color: .allCases.randomElement()!
					)
				)
				return .none
			}
		}
	}
}

struct OverviewView: View {

	let store: StoreOf<OverviewFeature>
	@AppStorage(UserDefaultKeys.latestPrimaryBudgetID.rawValue) private var lastUsedBudgetIDString = ""

	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			Group {
				if viewStore.budgets.isEmpty {
					ContentUnavailableView("Keine Budgets", systemImage: "folder")
				} else {
					List {
						BalanceDisplay(balance: viewStore.totalBalance)
						ForEach(viewStore.groupedBudgets.elements, id: \.key) { color, budgets in
							Section(color.localizedName) {
								ForEach(budgets) { budget in
									BudgetRow(budget: budget)
								}
							}
						}
					}
				}
			}
			.navigationTitle("Konto")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						viewStore.send(.historyButtonTapped)
					} label: {
						Label("Verlauf", systemImage: "clock")
					}
				}
				ToolbarItem(placement: .bottomBar) {
					Button {
						viewStore.send(.createBudgetButtonTapped)
					} label: {
						Label("Kategorien", systemImage: "folder.badge.plus")
					}
				}
				ToolbarItemGroup(placement: .bottomBar) {
					Spacer()
					Button("Saldo anpassen", systemImage: "eurosign") {
						viewStore.send(.balanceOperationButtonTapped)
					}
					.symbolVariant(.circle)
					.disabled(viewStore.groupedBudgets.isEmpty)
				}
			}
			//		.sheet(isPresented: $isCreatingBudget) {
			//			BudgetCreator()
			//		}
			//		.fullScreenCover(isPresented: $historyIsOpen) {
			//			BalanceHistory(budgets: model.budgets)
			//		}
			//		.fullScreenCover(isPresented: $isOperatingOnBalance) {
			//			BalanceOperator(
			//				primaryBudgetID:
			//					UUID(uuidString: lastUsedBudgetIDString) ?? model.budgets.randomElement()!.id
			//			)
			//			.environmentObject(model)
			//		}
		}
	}
}

private struct BalanceDisplay: View {
	let balance: Decimal

	var body: some View {
		HStack {
			Label {
				Text("Kontostand")
			} icon: {
				Image(systemName: "building.columns")
			}
			Spacer()
			Text(balance, format: .eur())
				.monospacedDigit()
		}
		.foregroundColor(.secondary)
	}
}

#Preview {
	NavigationStack {
		OverviewView(
			store: Store(
				initialState: OverviewFeature.State(
					budgets: [.mock]
				)
			) {
				OverviewFeature()
			}
		)
	}
}
