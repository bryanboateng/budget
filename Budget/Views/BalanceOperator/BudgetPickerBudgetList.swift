import ComposableArchitecture
import OrderedCollections
import SwiftUI

@Reducer
struct BudgetPickerBudgetListFeature {
	@ObservableState
	struct State {
		let budgets: IdentifiedArrayOf<Account.Budget>
		var chosenBudgetID: Account.Budget.ID?
	}
	enum Action {
		case budgetTapped(Account.Budget.ID)
		case delegate(Delegate)
		enum Delegate {
			case budgetPicked(Account.Budget.ID)
		}
	}

	var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .budgetTapped(let id):
				state.chosenBudgetID = id
				return .run { send in
					await send(.delegate(.budgetPicked(id)))
				}
			case .delegate:
				return .none
			}
		}
	}
}

struct BudgetPickerBudgetListView: View {
	let store: StoreOf<BudgetPickerBudgetListFeature>

	var body: some View {
		if self.store.budgets.isEmpty {
			ContentUnavailableView("Keine Budgets", systemImage: "circle")
		} else {
			List {
				ForEach(groupBudgets(self.store.budgets).elements, id: \.key) { color, budgets in
					Section(color.localizedName) {
						ForEach(budgets) { budget in
							Button(
								action: {
									self.store.send(.budgetTapped(budget.id))
								},
								label: {
									HStack {
										BudgetRow(budget: budget)
											.foregroundColor(.primary)
										Image(systemName: "checkmark")
											.opacity(budget.id == self.store.chosenBudgetID ? 1 : 0)
											.fontWeight(.semibold)
									}
								}
							)
						}
					}
				}
			}
		}
	}
}

#Preview {
	let chosenBudget = Account.Budget(
		id: UUID(),
		name: "Essen",
		color: .orange,
		balanceAdjustments: [
			Account.Budget.BalanceAdjustment(id: UUID(), date: .now, amount: 20.41)
		]
	)
	return NavigationStack {
		BudgetPickerBudgetListView(
			store: Store(
				initialState: BudgetPickerBudgetListFeature.State(
					budgets: [
						chosenBudget,
						Account.Budget(
							id: UUID(),
							name: "Bolzen",
							color: .red,
							balanceAdjustments: [.init(id: UUID(), date: .now, amount: 402)],
							monthlyAllocation: 90
						)
					],
					chosenBudgetID: chosenBudget.id
				)
			) {
				BudgetPickerBudgetListFeature()
			}
		)
	}
}
