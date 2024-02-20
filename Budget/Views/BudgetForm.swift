import ComposableArchitecture
import SwiftUI

@Reducer
struct BudgetFormFeature {
	@ObservableState
	struct State {
		var name = ""
		var color = Budget.Color.allCases.randomElement()!
		var projectionIsEnabled = false
		var monthlyAllocation: Decimal = 0
		var nameFieldIsFocused = true
	}
	enum Action: BindableAction {
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
	@Bindable var store: StoreOf<BudgetFormFeature>
	@FocusState var nameFieldIsFocused: Bool

	var body: some View {
		Form {
			Section("Name") {
				TextField("Name", text: self.$store.name, axis: .vertical)
					.focused($nameFieldIsFocused)
			}
			Section {
				Picker("Farbe", selection: self.$store.color) {
					ForEach(Budget.Color.allCases, id: \.self) { color in
						CirclebadgeLabel(color.localizedName, color: color)
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
