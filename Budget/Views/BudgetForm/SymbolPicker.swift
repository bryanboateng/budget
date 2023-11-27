import ComposableArchitecture
import SwiftUI

struct SymbolPickerFeature: Reducer {
	struct State: Equatable {
		let color: Budget.Color
		var pickedSymbol: String

		let symbols: [String] = {
			let root = try! PropertyListSerialization
				.propertyList(
					from: try! Data(
						contentsOf: URL(
							fileURLWithPath:
								Bundle.main.path(forResource: "name_availability", ofType: "plist")!
						)
					),
					format: nil
				) as! [String:[String:Any]]
			let symbol_availability = root["symbols"] as! [String: String]
			let moinsen = Set(
				symbol_availability
					.keys
					.map { symbol in
						Bundle.main.localizedString(
							forKey: symbol,
							value: nil,
							table: "name_aliases"
						)
					}
			)
			.filter { symbol in
				!["fill", "rtl", "ar", "he", "hi", "ja", "ko", "th", "zh"]
					.contains { suffix in
						symbol.hasSuffix(".\(suffix)")
					}
			}

			return moinsen
				.filter { symbol in
					guard symbol.contains(".fill.") else { return true }
					return !moinsen
						.contains(
							symbol.replacingOccurrences(of: ".fill.", with: ".")
						)
				}
				.sorted()
		}()

		@BindingState var searchText: String = ""

		var searchResults: [String] {
			let trimmedSearchText = searchText
				.trimmingCharacters(in: .whitespacesAndNewlines)
			if trimmedSearchText.isEmpty {
				return symbols
			} else {
				return symbols
					.filter { symbol in
						symbol.localizedStandardContains(trimmedSearchText)
					}
			}
		}
	}
	enum Action: BindableAction, Equatable {
		case binding(BindingAction<State>)
		case delegate(Delegate)
		case symbolPressed(symbol: String)
		enum Delegate {
			case symbolPicked
		}
	}
	var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .delegate:
				return .none
			case .symbolPressed(let symbol):
				state.pickedSymbol = symbol
				return .run { send in
					await send(.delegate(.symbolPicked))
				}
			}
		}
	}
}

struct SymbolPickerView: View {
	let store: StoreOf<SymbolPickerFeature>
	static let spacing: CGFloat = 8

	let columns = [
		GridItem(.adaptive(minimum: 100), spacing: spacing)
	]

	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			ScrollView {
				LazyVGrid(columns: columns, spacing: Self.spacing) {
					ForEach(viewStore.searchResults, id: \.self) { symbol in
						Button {
							viewStore.send(.symbolPressed(symbol: symbol))
						} label: {
							SymbolCell(
								isSelected: viewStore.pickedSymbol == symbol,
								symbol: symbol,
								color: viewStore.color
							)
						}
						.buttonStyle(.plain)
					}
				}
				.padding()
			}
			.scrollContentBackground(.hidden)
			.background(Color(UIColor.systemGroupedBackground))
			.navigationBarTitleDisplayMode(.inline)
			.searchable(
				text: viewStore.$searchText,
				placement: .navigationBarDrawer(displayMode: .always)
			)
		}
	}
}

#Preview {
	return NavigationStack {
		SymbolPickerView(
			store: Store(
				initialState: SymbolPickerFeature.State(
					color: .red,
					pickedSymbol: "rays"
				)
			) {
				SymbolPickerFeature()
			}
		)
	}
}
