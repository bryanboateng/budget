import ComposableArchitecture
import SwiftUI

@Reducer
struct AccountFormFeature {
	@ObservableState
	struct State {
		var name = ""
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

struct AccountFormView: View {
	@Bindable var store: StoreOf<AccountFormFeature>
	@FocusState var nameFieldIsFocused: Bool

	var body: some View {
		Form {
			Section("Name") {
				TextField("Name", text: self.$store.name, axis: .vertical)
					.focused($nameFieldIsFocused)
			}
		}
		.bind(self.$store.nameFieldIsFocused, to: self.$nameFieldIsFocused)
	}
}

#Preview {
	NavigationStack {
		AccountFormView(
			store: Store(
				initialState: AccountFormFeature.State(
					name: "Hello"
				)
			) {
				AccountFormFeature()
			}
		)
	}
}
