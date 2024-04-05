import ComposableArchitecture
import SwiftUI

@Reducer
struct BalanceOperatorFeature {
	@ObservableState
	struct State {
		@Shared(.fileStorage(.budgets)) var budgets: IdentifiedArrayOf<Budget> = []
		var absoluteAmount: Decimal = 0
		var operation: BalanceOperation = .adjustment
		var direction: AdjustmentBalanceOperationDirection = .outgoing
		var currencyFieldIsFocused: Bool = true
		var primaryBudgetID: Budget.ID?
		var secondaryBudgetID: Budget.ID?

		@Presents var destination: Destination.State?
	}
	enum Action: BindableAction {
		case binding(BindingAction<State>)
		case budgetFieldTapped(BudgetField)
		case cancelButtonTapped
		case confirmButtonTapped
		case destination(PresentationAction<Destination.Action>)
		enum BudgetField {
			case adjustment
			case transferSender
			case transferReceiver
		}
	}
	@Reducer
	enum Destination {
		case pickPrimaryBudget(BudgetPickerBudgetListFeature)
		case pickSecondaryBudget(BudgetPickerBudgetListFeature)
	}
	@Dependency(\.dismiss) var dismiss
	var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .budgetFieldTapped(let budgetField):
				switch budgetField {
				case .adjustment, .transferSender:
					state.destination = .pickPrimaryBudget(
						BudgetPickerBudgetListFeature.State(
							budgets: state.budgets,
							chosenBudgetID: state.primaryBudgetID
						)
					)
				case .transferReceiver:
					state.destination = .pickSecondaryBudget(
						BudgetPickerBudgetListFeature.State(
							budgets: state.budgets,
							chosenBudgetID: state.secondaryBudgetID
						)
					)
				}
				return .none
			case .cancelButtonTapped:
				return .run { _ in
					await self.dismiss()
				}
			case .confirmButtonTapped:
				switch state.operation {
				case .adjustment:
					let amount: Decimal = {
						switch state.direction {
						case .outgoing: -1 * state.absoluteAmount
						case .incoming: state.absoluteAmount
						}
					}()
					guard let id = state.primaryBudgetID else { return .none }
					guard var budget = state.budgets[id: id] else { return .none }
					budget.balanceAdjustments.insert(
						Budget.BalanceAdjustment(id: UUID(), date: .now, amount: amount)
					)
					state.budgets[id: id] = budget
				case .transfer:
					guard let primaryBudgetID = state.primaryBudgetID else { return .none }
					guard let secondaryBudgetID = state.secondaryBudgetID else { return .none }

					guard primaryBudgetID != secondaryBudgetID else { return .none }

					guard var primaryBudget = state.budgets[id: primaryBudgetID] else { return .none }
					guard var secondaryBudget = state.budgets[id: secondaryBudgetID] else { return .none }

					primaryBudget.balanceAdjustments.insert(
						Budget.BalanceAdjustment(
							id: UUID(),
							date: .now,
							amount: -1 * state.absoluteAmount
						)
					)
					secondaryBudget.balanceAdjustments.insert(
						Budget.BalanceAdjustment(
							id: UUID(),
							date: .now,
							amount: state.absoluteAmount
						)
					)
					state.budgets[id: primaryBudgetID] = primaryBudget
					state.budgets[id: secondaryBudgetID] = secondaryBudget
				}
				return .run { _ in
					await self.dismiss()
				}
			case .destination(.presented(.pickPrimaryBudget(.delegate(.budgetPicked(let id))))):
				state.primaryBudgetID = id
				state.destination = nil
				return .none
			case .destination(.presented(.pickSecondaryBudget(.delegate(.budgetPicked(let id))))):
				state.secondaryBudgetID = id
				state.destination = nil
				return .none
			case .destination:
				return .none
			}
		}
		.ifLet(\.$destination, action: \.destination)
	}
}

struct BalanceOperatorView: View {
	@Bindable var store: StoreOf<BalanceOperatorFeature>
	@FocusState var currencyFieldIsFocused: Bool
	@ScaledMetric private var fontSize: CGFloat = 65

	var body: some View {
		NavigationStack {
			Form {
				currencyField
				switch self.store.operation {
				case .adjustment:
					Section("Budget") {
						budgetField(for: .adjustment)
					}
					directionSection
				case .transfer:
					Section("Sender") {
						budgetField(for: .transferSender)
					}
					Section("Empfänger") {
						budgetField(for: .transferReceiver)
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
			.navigationDestination(
				item: self.$store.scope(
					state: \.destination?.pickPrimaryBudget,
					action: \.destination.pickPrimaryBudget
				)
			) { store in
				BudgetPickerBudgetListView(store: store)
					.navigationTitle("Budget auswählen")
					.navigationBarTitleDisplayMode(.inline)
			}
			.navigationDestination(
				item: self.$store.scope(
					state: \.destination?.pickSecondaryBudget,
					action: \.destination.pickSecondaryBudget
				)
			) { store in
				BudgetPickerBudgetListView(store: store)
					.navigationTitle("Budget auswählen")
					.navigationBarTitleDisplayMode(.inline)
			}
		}
	}

	private var currencyField: some View {
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
	}

	private func budgetField(
		for type: BalanceOperatorFeature.Action.BudgetField
	) -> some View {
		Button {
			self.store.send(.budgetFieldTapped(type))
		} label: {
			NavigationLink(destination: EmptyView()) {
				let budgetID = {
					switch type {
					case .adjustment, .transferSender:
						return self.store.state.primaryBudgetID
					case .transferReceiver:
						return self.store.state.secondaryBudgetID
					}
				}()
				if let budgetID, let budget = self.store.budgets[id: budgetID] {
					BudgetRow(budget: budget)
				} else {
					Text("Kein Budget")
						.foregroundStyle(.secondary)
				}
			}
		}
		.foregroundColor(Color(uiColor: .label))
	}

	private var directionSection: some View {
		Section("Richtung") {
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
				initialState: BalanceOperatorFeature.State(
					budgets: [
						Budget.mock,
						Budget(
							id: UUID(),
							name: "Bolzen",
							color: .red,
							balanceAdjustments: [.init(id: UUID(), date: .now, amount: 402)],
							monthlyAllocation: 90
						)
					]
				)
			) {
				BalanceOperatorFeature()
			}
		)
	}
}
