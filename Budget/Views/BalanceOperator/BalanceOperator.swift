import ComposableArchitecture
import SwiftUI

@Reducer
struct BalanceOperatorFeature {
	@ObservableState
	struct State {
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
		var absoluteAmount: Decimal = 0
		var operation: BalanceOperation = .adjustment
		var direction: AdjustmentBalanceOperationDirection = .outgoing
		var currencyFieldIsFocused: Bool = true
		var primaryBudgetID: Budget.ID?
		var secondaryBudgetID: Budget.ID?

		@Presents var pickPrimaryBudget: BudgetPickerBudgetListFeature.State?
		@Presents var pickSecondaryBudget: BudgetPickerBudgetListFeature.State?
	}
	enum Action: BindableAction {
		case binding(BindingAction<State>)
		case budgetFieldTapped(BudgetField)
		case cancelButtonTapped
		case cancelPickingBudgetButtonTapped
		case confirmButtonTapped
		case delegate(Delegate)
		case pickPrimaryBudget(PresentationAction<BudgetPickerBudgetListFeature.Action>)
		case pickSecondaryBudget(PresentationAction<BudgetPickerBudgetListFeature.Action>)
		enum BudgetField {
			case adjustment
			case transferSender
			case transferReceiver
		}
		enum Delegate {
			case cancelled
			case confirmed
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
			case .cancelButtonTapped:
				return .run { send in
					await send(.delegate(.cancelled))
				}
			case .confirmButtonTapped:
				return .run { send in
					await send(.delegate(.confirmed))
				}
			case .delegate:
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
		.ifLet(\.$pickPrimaryBudget, action: \.pickPrimaryBudget) {
			BudgetPickerBudgetListFeature()
		}
		.ifLet(\.$pickSecondaryBudget, action: \.pickSecondaryBudget) {
			BudgetPickerBudgetListFeature()
		}
	}
}

struct BalanceOperatorView: View {
	@Bindable var store: StoreOf<BalanceOperatorFeature>
	@FocusState var currencyFieldIsFocused: Bool
	@ScaledMetric private var fontSize: CGFloat = 65

	func woefn(
		budgetField: BalanceOperatorFeature.Action.BudgetField
	) -> some View {
		return Button(
			action: {
				self.store.send(.budgetFieldTapped(budgetField))
			},
			label: {
				let budgetID = {
					switch budgetField {
					case .adjustment, .transferSender:
						return self.store.state.primaryBudgetID
					case .transferReceiver:
						return self.store.state.secondaryBudgetID
					}
				}()

				if let budgetID, let budget = self.store.budgets[id: budgetID] {
					BudgetRow(budget: budget)
				} else {
					Label("Budget auswählen", systemImage: "square.dashed")
				}
			}
		)
	}

	var body: some View {
		NavigationStack {
			Form {
				CurrencyField(
					amount: self.$store.absoluteAmount,
					sign: {
						switch self.store.operation {
						case .adjustment:
							switch self.store.direction {
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
				switch self.store.operation {
				case .adjustment:
					Section("Budget") {
						woefn(budgetField: .adjustment)
					}
					Picker("Richtung", selection: self.$store.direction) {
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
						woefn(budgetField: .transferSender)
					}
					Section("Empfänger") {
						woefn(budgetField: .transferReceiver)
					}
				}
				Section {
					doneButton
				}
			}
			.bind(self.$store.currencyFieldIsFocused, to: self.$currencyFieldIsFocused)
			.navigationTitle("Saldo-Operation")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Picker("Saldo-Operation", selection: self.$store.operation) {
						Text("Anpassung").tag(BalanceOperation.adjustment)
						Text("Umbuchung").tag(BalanceOperation.transfer)
					}
					.pickerStyle(.segmented)
				}
				ToolbarItem(placement: .cancellationAction) {
					Button("Abbrechen") {
						self.store.send(.cancelButtonTapped)
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					doneButton
				}
			}
			.sheet(
				item: self.$store.scope(
					state: \.pickPrimaryBudget,
					action: \.pickPrimaryBudget
				)
			) { store in
				NavigationStack {
					BudgetPickerBudgetListView(store: store)
						.navigationTitle("Budget auswählen")
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button("Abbrechen") {
									self.store.send(.cancelPickingBudgetButtonTapped)
								}
							}
						}
				}
			}
			.sheet(
				item: self.$store.scope(
					state: \.pickSecondaryBudget,
					action: \.pickSecondaryBudget
				)
			) { store in
				NavigationStack {
					BudgetPickerBudgetListView(store: store)
						.navigationTitle("Budget auswählen")
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button("Abbrechen") {
									self.store.send(.cancelPickingBudgetButtonTapped)
								}
							}
						}
				}
			}
		}
	}

	private var doneButton: some View {
		Button("Fertig") {
			self.store.send(.confirmButtonTapped)
		}
		.disabled(
			self.store.absoluteAmount == 0.0 ||
			{
				guard let primaryBudgetID = self.store.primaryBudgetID else { return true }
				switch self.store.operation {
				case .adjustment:
					return false
				case .transfer:
					guard let secondaryBudgetID = self.store.secondaryBudgetID else { return true }
					return primaryBudgetID == secondaryBudgetID
				}
			}()
		)
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
