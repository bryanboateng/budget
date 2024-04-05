import ComposableArchitecture
import OrderedCollections
import SwiftUI

@Reducer
struct OverviewFeature {
	@ObservableState
	struct State {
		@Shared(.fileStorage(.budgets)) var budgets: IdentifiedArrayOf<Budget> = []

		@Shared(.appStorage("lastUsedPrimaryBudgetID"))
		var lastUsedPrimaryBudgetID: Budget.ID? = nil

		@Presents var destination: Destination.State?
		var historyIsOpen = false

		var totalBalance: Decimal {
			budgets.reduce(0) { partialResult, budget in
				partialResult + budget.balance
			}
		}
	}
	enum Action: BindableAction {
		case addBudgetButtonTapped
		case budgetRowTapped(Budget.ID)
		case balanceHistoryDoneButtonTapped
		case balanceOperationButtonTapped
		case binding(BindingAction<State>)
		case cancelBudgetButtonTapped
		case destination(PresentationAction<Destination.Action>)
		case historyButtonTapped
		case saveBudgetButtonTapped
	}
	@Reducer
	enum Destination {
		case addBudget(BudgetFormFeature)
		case detail(BudgetDetailFeature)
		case operateBalance(BalanceOperatorFeature)
	}
	@Dependency(\.uuid) var uuid
	var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .addBudgetButtonTapped:
				state.destination = .addBudget(BudgetFormFeature.State())
				return .none
			case .balanceHistoryDoneButtonTapped:
				state.historyIsOpen = false
				return .none
			case .balanceOperationButtonTapped:
				state.destination = .operateBalance(
					BalanceOperatorFeature.State(
						primaryBudgetID: state.lastUsedPrimaryBudgetID
					)
				)
				return .none
			case .binding:
				return .none
			case .budgetRowTapped(let budgetID):
				state.destination = .detail(
					BudgetDetailFeature.State(budgetID: budgetID)
				)
				return .none
			case .cancelBudgetButtonTapped:
				state.destination = nil
				return .none
			case .destination:
				return .none
			case .historyButtonTapped:
				state.historyIsOpen = true
				return .none
			case .saveBudgetButtonTapped:
				guard case let .addBudget(addBudget) = state.destination else { return .none }
				let trimmedName = addBudget.name.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmedName.isEmpty else { return .none }
				var newBudget = Budget(
					id: self.uuid(),
					name: trimmedName,
					color: addBudget.color
				)
				if addBudget.projectionIsEnabled {
					newBudget.setMonthlyAllocation(addBudget.monthlyAllocation)
				}
				state.budgets.append(newBudget)
				state.destination = nil
				return .none
			}
		}
		.ifLet(\.$destination, action: \.destination)
	}
}

struct OverviewView: View {
	@Bindable var store: StoreOf<OverviewFeature>

	var body: some View {
		Group {
			if self.store.budgets.isEmpty {
				ContentUnavailableView("Keine Budgets", systemImage: "circle")
			} else {
				List {
					BalanceDisplay(balance: self.store.totalBalance)
					ForEach(groupBudgets(self.store.budgets).elements, id: \.key) { color, budgets in
						Section(color.localizedName) {
							ForEach(budgets) { budget in
								Button {
									self.store.send(.budgetRowTapped(budget.id))
								} label: {
									NavigationLink(destination: EmptyView()) {
										BudgetRow(budget: budget)
									}
								}
								.foregroundColor(Color(uiColor: .label))
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
					self.store.send(.historyButtonTapped)
				} label: {
					Label("Verlauf", systemImage: "clock")
				}
			}
			ToolbarItem(placement: .bottomBar) {
				Button {
					self.store.send(.addBudgetButtonTapped)
				} label: {
					Label("Kategorien", systemImage: "circle.badge.plus")
				}
			}
			ToolbarItemGroup(placement: .bottomBar) {
				Spacer()
				Button("Saldo anpassen", systemImage: "eurosign") {
					self.store.send(.balanceOperationButtonTapped)
				}
				.symbolVariant(.circle)
			}
		}
		.sheet(
			item: self.$store.scope(
				state: \.destination?.addBudget,
				action: \.destination.addBudget
			)
		) { store in
			NavigationStack {
				BudgetFormView(store: store)
					.navigationTitle("Neues Budget")
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Button("Abbrechen") {
								self.store.send(.cancelBudgetButtonTapped)
							}
						}
						ToolbarItem(placement: .confirmationAction) {
							Button("Fertig") {
								self.store.send(.saveBudgetButtonTapped)
							}
						}
					}
			}
		}
		.fullScreenCover(
			isPresented: self.$store.historyIsOpen
		) {
			NavigationStack {
				BalanceHistory(budgets: self.store.budgets)
					.navigationTitle("Verlauf")
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItem(placement: .confirmationAction) {
							Button("Fertig") {
								self.store.send(.balanceHistoryDoneButtonTapped)
							}
						}
					}
			}
		}
		.fullScreenCover(
			item: self.$store.scope(
				state: \.destination?.operateBalance,
				action: \.destination.operateBalance
			)
		) { store in
			BalanceOperatorView(store: store)
		}
		.navigationDestination(
			item: self.$store.scope(
				state: \.destination?.detail,
				action: \.destination.detail
			)
		) { store in
			BudgetDetailView(store: store)
		}
	}
}

private struct BalanceDisplay: View {
	let balance: Decimal

	var body: some View {
		Label("Kontostand", systemImage: "building.columns")
			.foregroundColor(.secondary)
			.badge(
				Text(balance, format: .eur())
					.monospacedDigit()
			)
	}
}

#Preview {
	NavigationStack {
		OverviewView(
			store: Store(
				initialState: OverviewFeature.State(
					budgets: [Budget.mock]
				)
			) {
				OverviewFeature()
			}
		)
	}
}
