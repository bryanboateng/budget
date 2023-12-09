import ComposableArchitecture
import SwiftUI

@Reducer
struct SymbolPickerFeature {
	@ObservableState
	struct State {
		let color: Budget.Color
		var pickedSymbol: String
		var searchText: String = ""

		let symbols: [Symbol] = {
			let sfSymbolsBundle = Bundle(identifier: "com.apple.SFSymbolsFramework")!
			let coreGlyphsBundle = Bundle(
				path: sfSymbolsBundle.path(forResource: "CoreGlyphs", ofType: "bundle")!
			)!

			let filledSymbols = (
				try! PropertyListSerialization
					.propertyList(
						from: try! Data(
							contentsOf: URL(
								fileURLWithPath:
									coreGlyphsBundle.path(forResource: "nofill_to_fill", ofType: "strings")!
							)
						),
						format: nil
					) as! [String: String]
			).values

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
				.filter { symbolName in
					!(
						filledSymbols.contains(symbolName) ||
						["rtl", "ar", "he", "hi", "ja", "ko", "th", "zh"]
							.contains { suffix in
								symbolName.hasSuffix(".\(suffix)")
							}
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

			return symbolNames
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

		struct Symbol {
			let name: String
			let additionalSearchTerms: [String]
		}
	}
	enum Action: BindableAction {
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
	@Bindable var store: StoreOf<SymbolPickerFeature>
	static let spacing: CGFloat = 8

	let columns = [
		GridItem(.adaptive(minimum: 100), spacing: spacing)
	]

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: Self.spacing) {
				ForEach(self.store.searchResults, id: \.self) { symbol in
					Button {
						self.store.send(.symbolPressed(symbol: symbol))
					} label: {
						SymbolCell(
							isSelected: self.store.pickedSymbol == symbol,
							symbol: symbol,
							color: self.store.color
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
			text: self.$store.searchText,
			placement: .navigationBarDrawer(displayMode: .always)
		)
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
