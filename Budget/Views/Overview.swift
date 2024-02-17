import ComposableArchitecture
import OrderedCollections
import SwiftUI

@Reducer
struct OverviewFeature {
	@ObservableState
	struct State {

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

		@Presents var addBudget: BudgetFormFeature.State?
		var budgets: IdentifiedArrayOf<Budget> = []
		var historyIsOpen = false
		@Presents var operateBalance: BalanceOperatorFeature.State?

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
		case operateBalance(
			PresentationAction<BalanceOperatorFeature.Action>
		)
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
					monthlyAllocation: 0,
					nameFieldIsFocused: true
				)
				return .none
			case .addBudget:
				return .none
			case .balanceHistoryDoneButtonTapped:
				state.historyIsOpen = false
				return .none
			case .balanceOperationButtonTapped:
				state.operateBalance = BalanceOperatorFeature.State()
				return .none
			case .binding:
				return .none
			case .cancelBudgetButtonTapped:
				state.addBudget = nil
				return .none
			case .historyButtonTapped:
				state.historyIsOpen = true
				return .none
			case .operateBalance(.presented(.delegate(let delegate))):
				switch delegate {
				case .cancelled: break
				case .confirmed:
					guard let operateBalance = state.operateBalance else { return .none }
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
				state.operateBalance = nil
				return .none
			case .operateBalance:
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
		.ifLet(\.$addBudget, action: \.addBudget) {
			BudgetFormFeature()
		}
		.ifLet(\.$operateBalance, action: \.operateBalance) {
			BalanceOperatorFeature()
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
				state: \.addBudget,
				action: \.addBudget
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
				state: \.operateBalance,
				action: \.operateBalance
			)
		) { store in
			BalanceOperatorView(store: store)
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
