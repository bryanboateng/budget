import ComposableArchitecture
import OrderedCollections
import SwiftUI

struct OverviewFeature: Reducer {
	struct State: Equatable {

		init(
			addBudget: BudgetFormFeature.State? = nil,
			historyIsOpen: Bool = false
		) {
			self.addBudget = addBudget
			self.historyIsOpen = historyIsOpen

			do {
				@Dependency(\.dataManager.load) var loadData
				self.budgets = try JSONDecoder().decode(
					IdentifiedArrayOf<Budget>.self,
					from: loadData(.budgets)
				)
			} catch {
				self.budgets = []
			}
		}

		@PresentationState var addBudget: BudgetFormFeature.State?
		var budgets: IdentifiedArrayOf<Budget> = []
		@BindingState var historyIsOpen = false

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
	enum Action: BindableAction {
		case addBudgetButtonTapped
		case addBudget(PresentationAction<BudgetFormFeature.Action>)
		case balanceHistoryDoneButtonTapped
		case balanceOperationButtonTapped
		case binding(BindingAction<State>)
		case cancelBudgetButtonTapped
		case historyButtonTapped
		case saveBudgetButtonTapped
	}
	@Dependency(\.uuid) var uuid
	var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .addBudgetButtonTapped:
				state.addBudget = BudgetFormFeature.State(
					name: "",
					symbol: "",
					color: .allCases.randomElement()!,
					projectionIsEnabled: false,
					monthlyAllocation: 0
				)
				return .none
			case .addBudget:
				return .none
			case .balanceHistoryDoneButtonTapped:
				state.historyIsOpen = false
				return .none
			case .balanceOperationButtonTapped:
				return .none
			case .binding:
				return .none
			case .cancelBudgetButtonTapped:
				state.addBudget = nil
				return .none
			case .historyButtonTapped:
				state.historyIsOpen = true
				return .none
			case .saveBudgetButtonTapped:
				guard let addBudget = state.addBudget else { return .none }
				let trimmedName = addBudget.name.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmedName.isEmpty else { return .none }
				guard UIImage(systemName: addBudget.symbol) != nil else { return .none }
					var newBudget = Budget(
						id: self.uuid(),
						name: trimmedName,
						symbol: addBudget.symbol,
						color: addBudget.color
					)
				if addBudget.projectionIsEnabled {
					newBudget.setMonthlyAllocation(addBudget.monthlyAllocation)
				}
				state.budgets.append(newBudget)
				state.addBudget = nil
				return .none
			}
		}
		.ifLet(\.$addBudget, action: /Action.addBudget) {
			BudgetFormFeature()
		}
	}
}

struct OverviewView: View {
	let store: StoreOf<OverviewFeature>

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
									NavigationLink(
										state: AppFeature.Path.State.detail(
											BudgetDetailFeature.State(budget: budget)
										)
									) {
										BudgetRow(budget: budget)
									}
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
						viewStore.send(.addBudgetButtonTapped)
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
			.sheet(
				store: self.store.scope(
					state: \.$addBudget,
					action: { .addBudget($0) }
				)
			) { store in
				NavigationStack {
					BudgetFormView(store: store)
						.navigationTitle("Neues Budget")
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button("Abbrechen") {
									viewStore.send(.cancelBudgetButtonTapped)
								}
							}
							ToolbarItem(placement: .confirmationAction) {
								Button("Fertig") {
									viewStore.send(.saveBudgetButtonTapped)
								}
//								.disabled(
//									viewStore.addBudget?.name.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//									viewStore.addBudget?.symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//								)
							}
						}
				}
			}
			.fullScreenCover(
				isPresented: viewStore.$historyIsOpen
			) {
				NavigationStack {
					BalanceHistory(budgets: viewStore.budgets)
						.navigationTitle("Verlauf")
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .confirmationAction) {
								Button("Fertig") {
									viewStore.send(.balanceHistoryDoneButtonTapped)
								}
							}
						}
				}
			}
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
				initialState: OverviewFeature.State()
			) {
				OverviewFeature()
			} withDependencies: {
				$0.dataManager = .mock(
					initialData: try? JSONEncoder().encode([Budget.mock])
				)
			}
		)
	}
}
