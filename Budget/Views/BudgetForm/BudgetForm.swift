import ComposableArchitecture
import SwiftUI

@Reducer
struct BudgetFormFeature {
	@ObservableState
	struct State {
		var name = ""
		var symbol = ""
		var color = Budget.Color.allCases.randomElement()!
		var projectionIsEnabled = false
		var monthlyAllocation: Decimal = 0
		var nameFieldIsFocused = true
		@Presents var pickSymbol: SymbolPickerFeature.State?
	}
	enum Action: BindableAction {
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
		.ifLet(\.$pickSymbol, action: \.pickSymbol) {
			SymbolPickerFeature()
		}
	}
}

struct BudgetFormView: View {
	@Bindable var store: StoreOf<BudgetFormFeature>
	@FocusState var nameFieldIsFocused: Bool

	var body: some View {
		Form {
			Section {
				VStack(alignment: .center) {
					Group {
						if UIImage(systemName: self.store.symbol) != nil {
							Image(systemName: self.store.symbol)
						} else {
							Image(systemName: "questionmark.square.dashed")
								.foregroundStyle(.secondary)
						}
					}
					.foregroundStyle(self.store.color.swiftUIColor)
					.font(.system(size: 100))
					.frame(maxWidth: .infinity, alignment: .center)
					Button("Symbol auswählen") {
						self.store.send(.pickSymbolButtonTapped)
					}
					.buttonStyle(.bordered)
					.buttonBorderShape(.capsule)
				}
			}
			.listRowBackground(Color(UIColor.systemGroupedBackground))
			Section("Name") {
				TextField("Name", text: self.$store.name, axis: .vertical)
					.focused($nameFieldIsFocused)
			}
			Section {
				Picker("Farbe", selection: self.$store.color) {
					ForEach(Budget.Color.allCases, id: \.self) { color in
						HStack{
							Image(systemName: "circlebadge")
								.symbolVariant(.fill)
								.foregroundStyle(color.swiftUIColor)
							Text(color.localizedName)
						}
					}
				}
				.pickerStyle(.navigationLink)
			}
			Section("Monatliche Zuweisung") {
				Toggle("Monatliche Zuweisung", isOn: self.$store.projectionIsEnabled)
				if self.store.projectionIsEnabled {
					TextField(
						"Monatliche Zuweisung",
						value: self.$store.monthlyAllocation,
						format: .number.precision(.fractionLength(2))
					)
					.keyboardType(.decimalPad)
				}
			}
		}
		.bind(self.$store.nameFieldIsFocused, to: self.$nameFieldIsFocused)
		.sheet(
			item: self.$store.scope(
				state: \.pickSymbol,
				action: \.pickSymbol
			)
		) { store in
			NavigationStack {
				SymbolPickerView(store: store)
					.navigationTitle("Symbol auswählen")
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Button("Abbrechen") {
								self.store.send(.symbolPickerCancelButtonTapped)
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
