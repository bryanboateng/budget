import ComposableArchitecture
import OrderedCollections
import SwiftUI

@Reducer
struct OverviewFeature {
	@ObservableState
	struct State {

		init(
			destination: Destination.State? = nil,
			historyIsOpen: Bool = false
		) {
			self.destination = destination
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

		var budgets: IdentifiedArrayOf<Budget> = []
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
	@Dependency(\.continuousClock) var clock
	@Dependency(\.dataManager.save) var saveData
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
				state.destination = .operateBalance(BalanceOperatorFeature.State())
				return .none
			case .binding:
				return .none
			case .budgetRowTapped(let budgetID):
				guard let budget = state.budgets[id: budgetID] else { return .none }
				state.destination = .detail(
					BudgetDetailFeature.State(budget: budget)
				)
				return .none
			case .cancelBudgetButtonTapped:
				state.destination = nil
				return .none
			case .destination(.presented(let destination)):
				return reduceDestination(state: &state, action: destination)
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

		Reduce { state, _ in
				.run { [budgets = state.budgets] _ in
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

	func reduceDestination(
		state: inout OverviewFeature.State,
		action: Destination.Action
	) -> Effect<OverviewFeature.Action> {
		switch action {
		case .addBudget:
			return .none
		case .detail(.delegate(let delegate)):
			switch delegate {
			case let .budgetUpdated(budget):
				state.budgets[id: budget.id] = budget
			case let .deleteStandup(id: id):
				state.budgets.remove(id: id)
			}
			return .none
		case .detail:
			return .none
		case .operateBalance(.delegate(let delegate)):
			switch delegate {
			case .cancelled: break
			case .confirmed:
				guard case let .operateBalance(operateBalance) = state.destination else { return .none }
				switch operateBalance.operation {
				case .adjustment:
					let amount: Decimal = {
						switch operateBalance.direction {
						case .outgoing: -1 * operateBalance.absoluteAmount
						case .incoming: operateBalance.absoluteAmount
						}
					}()
					guard let id = operateBalance.primaryBudgetID else { return .none }
					guard var budget = state.budgets[id: id] else { return .none }
					budget.balanceAdjustments.insert(
						Budget.BalanceAdjustment(id: UUID(), date: .now, amount: amount)
					)
					state.budgets[id: id] = budget
				case .transfer:
					guard let primaryBudgetID = operateBalance.primaryBudgetID else { return .none }
					guard let secondaryBudgetID = operateBalance.secondaryBudgetID else { return .none }

					guard primaryBudgetID != secondaryBudgetID else { return .none }

					guard var primaryBudget = state.budgets[id: primaryBudgetID] else { return .none }
					guard var secondaryBudget = state.budgets[id: secondaryBudgetID] else { return .none }

					primaryBudget.balanceAdjustments.insert(
						Budget.BalanceAdjustment(
							id: UUID(),
							date: .now,
							amount: -1 * operateBalance.absoluteAmount
						)
					)
					secondaryBudget.balanceAdjustments.insert(
						Budget.BalanceAdjustment(
							id: UUID(),
							date: .now,
							amount: operateBalance.absoluteAmount
						)
					)
					state.budgets[id: primaryBudgetID] = primaryBudget
					state.budgets[id: secondaryBudgetID] = secondaryBudget
				}
			}
			state.destination = nil
			return .none
		case .operateBalance:
			return .none
		}
	}
}

struct OverviewView: View {
	@Bindable var store: StoreOf<OverviewFeature>

	var body: some View {
		Group {
			if self.store.budgets.isEmpty {
				ContentUnavailableView("Keine Budgets", systemImage: "folder")
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
					Label("Kategorien", systemImage: "folder.badge.plus")
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
