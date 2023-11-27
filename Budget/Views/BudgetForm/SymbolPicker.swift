import ComposableArchitecture
import SwiftUI

struct SymbolPickerFeature: Reducer {
	struct State: Equatable {
		let color: Budget.Color
		var pickedSymbol: String
		@BindingState var searchText: String = ""

		let symbols: [Symbol] = {
			let coreGlyphsBundle = Bundle(identifier: "com.apple.CoreGlyphs")!
			let symbolNames = (
				try! PropertyListSerialization
					.propertyList(
						from: try! Data(
							contentsOf: URL(
								fileURLWithPath:
									coreGlyphsBundle.path(forResource: "symbol_order", ofType: "plist")!
							)
						),
						format: nil
					) as! [String]
			)
				.filter { symbol in
					!["fill", "rtl", "ar", "he", "hi", "ja", "ko", "th", "zh"]
						.contains { suffix in
							symbol.hasSuffix(".\(suffix)")
						}
				}

			let nwe = symbolNames
				.filter { symbolName in
					guard symbolName.contains(".fill.") else { return true }
					return !symbolNames
						.contains(
							symbolName.replacingOccurrences(of: ".fill.", with: ".")
						)
				}

			let symbolSearch = try! PropertyListSerialization
				.propertyList(
					from: try! Data(
						contentsOf: URL(
							fileURLWithPath:
								coreGlyphsBundle.path(forResource: "symbol_search", ofType: "plist")!
						)
					),
					format: nil
				) as! [String:[String]]

			return nwe
				.map { symbolName in
					return Symbol(
						name: symbolName,
						additionalSearchTerms: symbolSearch[symbolName] ?? []
					)
				}
		}()

		var searchResults: [String] {
			let trimmedSearchText = searchText
				.trimmingCharacters(in: .whitespacesAndNewlines)
			if trimmedSearchText.isEmpty {
				return symbols.map(\.name)
			} else {
				return symbols
					.filter { symbol in
						symbol.name.localizedStandardContains(trimmedSearchText) ||
						symbol.additionalSearchTerms.contains { searchTerm in
							searchTerm.localizedStandardContains(trimmedSearchText)
						}
					}
					.map(\.name)
			}
		}

		struct Symbol: Equatable {
			let name: String
			let additionalSearchTerms: [String]
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
