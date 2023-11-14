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
	}
	enum Action: BindableAction, Equatable {
		case binding(BindingAction<State>)
	}
	var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			}
		}
	}
}

struct BudgetFormView: View {
	let store: StoreOf<BudgetFormFeature>
	@FocusState var nameFieldIsFocused: Bool

	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			Form {
				Section("Name") {
					TextField("Name", text: viewStore.$name, axis: .vertical)
						.focused($nameFieldIsFocused)
				}
				Section("Symbol") {
					Group {
						if UIImage(systemName: viewStore.symbol) != nil {
							Image(systemName: viewStore.symbol)
						} else {
							Image(systemName: "questionmark.diamond")
								.foregroundStyle(.secondary)
								.symbolVariant(.fill)
						}
					}
					.foregroundStyle(viewStore.color.swiftUIColor)
					.font(.system(size: 100))
					.frame(maxWidth: .infinity, alignment: .center)
					TextField("Symbol", text: viewStore.$symbol, axis: .vertical)
						.autocorrectionDisabled(true)
						.textInputAutocapitalization(.never)
						.keyboardType(.asciiCapable)
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
