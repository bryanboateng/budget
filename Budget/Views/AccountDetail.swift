import ComposableArchitecture
import OrderedCollections
import SwiftUI

@Reducer
struct AccountDetailFeature {
	@ObservableState
	struct State {
		var account: Account
		@Presents var destination: Destination.State?
		var historyIsOpen = false

		var totalBalance: Decimal {
			account.budgets.reduce(0) { partialResult, budget in
				partialResult + budget.balance
			}
		}
	}
	enum Action: BindableAction {
		case balanceHistoryDoneButtonTapped
		case balanceOperationButtonTapped
		case binding(BindingAction<State>)
		case budgetRowTapped(Account.Budget.ID)
		case createBudgetButtonTapped
		case createBudgetCancelButtonTapped
		case createBudgetSaveButtonTapped
		case delegate(Delegate)
		case destination(PresentationAction<Destination.Action>)
		case historyButtonTapped
		enum Delegate {
//			case deleteStandup(id: Account.Budget.ID)
			case accountChanged(Account)
		}
	}
	@Reducer
	enum Destination {
		case createBudget(BudgetFormFeature)
		case detail(BudgetDetailFeature)
		case operateBalance(BalanceOperatorFeature)
	}
	@Dependency(\.uuid) var uuid
	var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .balanceHistoryDoneButtonTapped:
				state.historyIsOpen = false
				return .none
			case .balanceOperationButtonTapped:
				state.destination = .operateBalance(
					BalanceOperatorFeature.State(budgets: state.account.budgets)
				)
				return .none
			case .binding:
				return .none
			case .budgetRowTapped(let budgetID):
				guard let budget = state.account.budgets[id: budgetID] else { return .none }
				state.destination = .detail(
					BudgetDetailFeature.State(budget: budget)
				)
				return .none
			case .createBudgetButtonTapped:
				state.destination = .createBudget(BudgetFormFeature.State())
				return .none
			case .createBudgetCancelButtonTapped:
				state.destination = nil
				return .none
			case .createBudgetSaveButtonTapped:
				guard case .createBudget(let budgetForm) = state.destination else { return .none }
				let trimmedName = budgetForm.name.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmedName.isEmpty else { return .none }
				var budget = Account.Budget(
					id: self.uuid(),
					name: trimmedName,
					color: budgetForm.color
				)
				if budgetForm.projectionIsEnabled {
					budget.setMonthlyAllocation(budgetForm.monthlyAllocation)
				}
				state.account.budgets.append(budget)
				state.destination = nil
				return .none
			case .delegate:
				return .none
			case .destination(.presented(let destination)):
				return reduceDestination(state: &state, action: destination)
			case .destination:
				return .none
			case .historyButtonTapped:
				state.historyIsOpen = true
				return .none
			}
		}
		.ifLet(\.$destination, action: \.destination)
		.onChange(of: \.account) { _, newAccount in
			Reduce { state, action in
					.send(.delegate(.accountChanged(newAccount)))
			}
		}
	}

	func reduceDestination(
		state: inout AccountDetailFeature.State,
		action: Destination.Action
	) -> Effect<AccountDetailFeature.Action> {
		switch action {
		case .createBudget:
			return .none
		case .detail(.delegate(let delegate)):
			switch delegate {
			case let .budgetUpdated(budget):
				state.account.budgets[id: budget.id] = budget
			case let .deleteStandup(id: id):
				state.account.budgets.remove(id: id)
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
					guard var budget = state.account.budgets[id: id] else { return .none }
					budget.balanceAdjustments.append(
						Account.Budget.BalanceAdjustment(id: self.uuid(), date: .now, amount: amount)
					)
					state.account.budgets[id: id] = budget
				case .transfer:
					guard let primaryBudgetID = operateBalance.primaryBudgetID else { return .none }
					guard let secondaryBudgetID = operateBalance.secondaryBudgetID else { return .none }

					guard primaryBudgetID != secondaryBudgetID else { return .none }

//					guard var primaryBudget = state.budgets[id: primaryBudgetID] else { return .none }
//					guard var secondaryBudget = state.budgets[id: secondaryBudgetID] else { return .none }
//
//					primaryBudget.balanceAdjustments.insert(
//						Account.Budget.BalanceAdjustment(
//							id: self.uuid(),
//							date: .now,
//							amount: -1 * operateBalance.absoluteAmount
//						)
//					)
//					secondaryBudget.balanceAdjustments.insert(
//						Account.Budget.BalanceAdjustment(
//							id: self.uuid(),
//							date: .now,
//							amount: operateBalance.absoluteAmount
//						)
//					)
//					state.budgets[id: primaryBudgetID] = primaryBudget
//					state.budgets[id: secondaryBudgetID] = secondaryBudget
				}
			}
			state.destination = nil
			return .none
		case .operateBalance:
			return .none
		}
	}
}

struct AccountDetailView: View {
	@Bindable var store: StoreOf<AccountDetailFeature>

	var body: some View {
		Group {
			if self.store.account.budgets.isEmpty {
				ContentUnavailableView("Keine Budgets", systemImage: "circle")
			} else {
				List {
					BalanceDisplay(balance: self.store.account.balance)
					ForEach(groupBudgets(self.store.account.budgets).elements, id: \.key) { color, budgets in
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
		.navigationTitle(self.store.account.name)
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
					self.store.send(.createBudgetButtonTapped)
				} label: {
					Label("Neues Budget", systemImage: "circle.badge.plus")
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
				state: \.destination?.createBudget,
				action: \.destination.createBudget
			)
		) { store in
			NavigationStack {
				BudgetFormView(store: store)
					.navigationTitle("Neues Budget")
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Button("Abbrechen") {
								self.store.send(.createBudgetCancelButtonTapped)
							}
						}
						ToolbarItem(placement: .confirmationAction) {
							Button("Fertig") {
								self.store.send(.createBudgetSaveButtonTapped)
							}
						}
					}
			}
		}
		.fullScreenCover(
			isPresented: self.$store.historyIsOpen
		) {
			NavigationStack {
				BalanceHistory(budgets: self.store.account.budgets)
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
		AccountDetailView(
			store: Store(
				initialState: AccountDetailFeature.State(
					account: Account(
						id: UUID(),
						name: "Sparkasse",
						budgets: [
							Account.Budget(
								id: UUID(),
								name: "Essen",
								color: .orange,
								balanceAdjustments: [
									.init(id: UUID(), date: .now, amount: 20.41)
								]
							)
						]
					)
				)
			) {
				AccountDetailFeature()
			}
		)
	}
}
