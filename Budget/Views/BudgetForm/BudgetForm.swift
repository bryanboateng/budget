import ComposableArchitecture
import SwiftUI

struct BudgetFormFeature: Reducer {
	struct State: Equatable {
		@BindingState var name: String
		@BindingState var symbol: String
		@BindingState var color: Budget.Color
		@BindingState var projectionIsEnabled: Bool
		@BindingState var monthlyAllocation: Decimal
		@BindingState var nameFieldIsFocused: Bool = true
		@PresentationState var pickSymbol: SymbolPickerFeature.State?
	}
	enum Action: BindableAction, Equatable {
		case binding(BindingAction<State>)
		case pickSymbol(PresentationAction<SymbolPickerFeature.Action>)
		case pickSymbolButtonTapped
		case symbolPickerCancelButtonTapped
	}
	var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .pickSymbol(.presented(.delegate(let delegate))):
				switch delegate {
				case .symbolPicked:
					guard let pickSymbol = state.pickSymbol else { return .none }
					state.symbol = pickSymbol.pickedSymbol
					state.pickSymbol = nil
				}
				return .none
			case .pickSymbol:
				return .none
			case .pickSymbolButtonTapped:
				state.pickSymbol = .init(
					color: state.color,
					pickedSymbol: state.symbol
				)
				return .none
			case .symbolPickerCancelButtonTapped:
				state.pickSymbol = nil
				return .none
			}
		}
		.ifLet(\.$pickSymbol, action: /Action.pickSymbol) {
			SymbolPickerFeature()
		}
	}
}

struct BudgetFormView: View {
	let store: StoreOf<BudgetFormFeature>
	@FocusState var nameFieldIsFocused: Bool

	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			Form {
				Section {
					VStack(alignment: .center) {
						Group {
							if UIImage(systemName: viewStore.symbol) != nil {
								Image(systemName: viewStore.symbol)
							} else {
								Image(systemName: "questionmark.square.dashed")
									.foregroundStyle(.secondary)
							}
						}
						.foregroundStyle(viewStore.color.swiftUIColor)
						.font(.system(size: 100))
						.frame(maxWidth: .infinity, alignment: .center)
						Button("Symbol auswählen") {
							viewStore.send(.pickSymbolButtonTapped)
						}
						.buttonStyle(.bordered)
						.buttonBorderShape(.capsule)
					}
				}
				.listRowBackground(Color(UIColor.systemGroupedBackground))
				Section("Name") {
					TextField("Name", text: viewStore.$name, axis: .vertical)
						.focused($nameFieldIsFocused)
				}
				Section {
					Picker("Farbe", selection: viewStore.$color) {
						ForEach(Budget.Color.allCases, id: \.self) { color in
							Text(color.localizedName)
						}
					}
					.pickerStyle(.menu)
				}
				Section("Monatliche Zuweisung") {
					Toggle("Monatliche Zuweisung", isOn: viewStore.$projectionIsEnabled)
					if viewStore.projectionIsEnabled {
						TextField(
							"Monatliche Zuweisung",
							value: viewStore.$monthlyAllocation,
							format: .number.precision(.fractionLength(2))
						)
						.keyboardType(.decimalPad)
					}
				}
			}
			.bind(viewStore.$nameFieldIsFocused, to: self.$nameFieldIsFocused)
			.sheet(
				store: self.store.scope(
					state: \.$pickSymbol,
					action: { .pickSymbol($0) }
				)
			) { store in
				NavigationStack {
					SymbolPickerView(store: store)
						.navigationTitle("Symbol auswählen")
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button("Abbrechen") {
									viewStore.send(.symbolPickerCancelButtonTapped)
								}
							}
						}
				}
			}
		}
	}
}

#Preview {
	let budget = Budget.mock
	let projection = budget.projection
	return NavigationStack {
		BudgetFormView(
			store: Store(
				initialState: BudgetFormFeature.State(
					name: budget.name,
					symbol: budget.symbol,
					color: budget.color,
					projectionIsEnabled: projection != nil,
					monthlyAllocation: projection?.monthlyAllocation ?? 0
				)
			) {
				BudgetFormFeature()
			}
		)
	}
}
