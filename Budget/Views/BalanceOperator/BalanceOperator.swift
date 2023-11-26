import ComposableArchitecture
import SwiftUI

struct BalanceOperatorFeature: Reducer {
	struct State: Equatable {
		init() {
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
		@BindingState var absoluteAmount: Decimal = 0
		@BindingState var operation: BalanceOperation = .adjustment
		@BindingState var direction: AdjustmentBalanceOperationDirection = .outgoing
		@BindingState var currencyFieldIsFocused: Bool = true
		@BindingState var primaryBudgetID: Budget.ID?
		@BindingState var secondaryBudgetID: Budget.ID?

		@PresentationState var pickPrimaryBudget: BudgetPickerBudgetListFeature.State?
		@PresentationState var pickSecondaryBudget: BudgetPickerBudgetListFeature.State?
	}
	enum Action: BindableAction, Equatable {
		case binding(BindingAction<State>)
		case budgetFieldTapped(BudgetField)
		case cancelPickingBudgetButtonTapped
		case pickPrimaryBudget(PresentationAction<BudgetPickerBudgetListFeature.Action>)
		case pickSecondaryBudget(PresentationAction<BudgetPickerBudgetListFeature.Action>)
		enum BudgetField {
			case adjustment
			case transferSender
			case transferReceiver
		}
	}
	var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .budgetFieldTapped(let budgetField):
				switch budgetField {
				case .adjustment, .transferSender:
					state.pickPrimaryBudget = BudgetPickerBudgetListFeature.State(
						budgets: state.budgets,
						chosenBudgetID: state.primaryBudgetID
					)
				case .transferReceiver:
					state.pickSecondaryBudget = BudgetPickerBudgetListFeature.State(
						budgets: state.budgets,
						chosenBudgetID: state.secondaryBudgetID
					)
				}
				return .none
			case .cancelPickingBudgetButtonTapped:
				state.pickPrimaryBudget = nil
				state.pickSecondaryBudget = nil
				return .none
			case .pickPrimaryBudget(.presented(.delegate(let delegate))):
				switch delegate {
				case .budgetPicked(let id):
					state.primaryBudgetID = id
					state.pickPrimaryBudget = nil
				}
				return .none
			case .pickPrimaryBudget:
				return .none
			case .pickSecondaryBudget(.presented(.delegate(let delegate))):
				switch delegate {
				case .budgetPicked(let id):
					state.secondaryBudgetID = id
					state.pickSecondaryBudget = nil
				}
				return .none
			case .pickSecondaryBudget:
				return .none
			}
		}
		.ifLet(\.$pickPrimaryBudget, action: /Action.pickPrimaryBudget) {
			BudgetPickerBudgetListFeature()
		}
		.ifLet(\.$pickSecondaryBudget, action: /Action.pickSecondaryBudget) {
			BudgetPickerBudgetListFeature()
		}
	}
}

struct BalanceOperatorView: View {
	let store: StoreOf<BalanceOperatorFeature>
	@FocusState var currencyFieldIsFocused: Bool
	@ScaledMetric private var fontSize: CGFloat = 65

	func woefn(
		viewStore: ViewStore<BalanceOperatorFeature.State, BalanceOperatorFeature.Action>,
		state: BalanceOperatorFeature.State,
		budgetField: BalanceOperatorFeature.Action.BudgetField
	) -> some View {
		return Button(
			action: {
				viewStore.send(.budgetFieldTapped(budgetField))
			},
			label: {
				let budgetID = {
					switch budgetField {
					case .adjustment, .transferSender:
						return state.primaryBudgetID
					case .transferReceiver:
						return state.secondaryBudgetID
					}
				}()

				if let budgetID, let budget = viewStore.budgets[id: budgetID] {
					BudgetRow(budget: budget)
				} else {
					Label("Budget auswählen", systemImage: "square.dashed")
				}
			}
		)
	}

	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			Form {
				CurrencyField(
					amount: viewStore.$absoluteAmount,
					sign: {
						switch viewStore.operation {
						case .adjustment:
							switch viewStore.direction {
							case .outgoing: return .minus
							case .incoming: return .plus
							}
						case .transfer:
							return nil
						}
					}(),
					fontSize: fontSize
				)
				.focused($currencyFieldIsFocused)
				.frame(maxWidth: .infinity, alignment: .center)
				.listRowBackground(Color(UIColor.systemGroupedBackground))
				switch viewStore.operation {
				case .adjustment:
					Section("Budget") {
						woefn(viewStore: viewStore, state: viewStore.state, budgetField: .adjustment)
					}
					Picker("Richtung", selection: viewStore.$direction) {
						ForEach(AdjustmentBalanceOperationDirection.allCases, id: \.self) { color in
							Text(
								{
									switch color {
									case .outgoing: "Ausgabe"
									case .incoming: "Einnahme"
									}
								}()
							)
						}
					}
					.pickerStyle(.menu)
				case .transfer:
					Section("Sender") {
						woefn(viewStore: viewStore, state: viewStore.state, budgetField: .transferSender)
					}
					Section("Empfänger") {
						woefn(viewStore: viewStore, state: viewStore.state, budgetField: .transferReceiver)
					}
				}
			}
			.bind(viewStore.$currencyFieldIsFocused, to: self.$currencyFieldIsFocused)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Picker("Saldo-Operation", selection: viewStore.$operation) {
						Text("Anpassung").tag(BalanceOperation.adjustment)
						Text("Umbuchung").tag(BalanceOperation.transfer)
					}
					.pickerStyle(.segmented)
				}
			}
			.sheet(
				store: self.store.scope(
					state: \.$pickPrimaryBudget,
					action: { .pickPrimaryBudget($0) }
				)
			) { store in
				NavigationStack {
					BudgetPickerBudgetListView(store: store)
						.navigationTitle("Budget auswählen")
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button("Abbrechen") {
									viewStore.send(.cancelPickingBudgetButtonTapped)
								}
							}
						}
				}
			}
			.sheet(
				store: self.store.scope(
					state: \.$pickSecondaryBudget,
					action: { .pickSecondaryBudget($0) }
				)
			) { store in
				NavigationStack {
					BudgetPickerBudgetListView(store: store)
						.navigationTitle("Budget auswählen")
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button("Abbrechen") {
									viewStore.send(.cancelPickingBudgetButtonTapped)
								}
							}
						}
				}
			}
		}
	}
}

#Preview {
	NavigationStack {
		BalanceOperatorView(
			store: Store(
				initialState: BalanceOperatorFeature.State()
			) {
				BalanceOperatorFeature()
			} withDependencies: {
				$0.dataManager = .mock(
					initialData: try? JSONEncoder().encode([
						Budget.mock,
						Budget(
							id: UUID(),
							name: "Bolzen",
							symbol: "steeringwheel",
							color: .red,
							balanceAdjustments: [.init(id: UUID(), date: .now, amount: 402)],
							monthlyAllocation: 90
						)
					])
				)
			}
		)
	}
}
