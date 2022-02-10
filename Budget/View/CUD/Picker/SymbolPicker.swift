import SwiftUI
import Collections

struct SymbolPicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @Binding var selectedSymbol: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(searchResult.keys, id: \.self) { category in
                    DisclosureGroup {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 75), spacing: 10)], spacing: 10) {
                            ForEach(searchResult[category]!, id: \.self) { symbol in
                                Button {
                                    self.selectedSymbol = symbol
                                    dismiss()
                                } label: {
                                    Image(systemName: symbol)
                                        .font(.system(size: 26, weight: .regular))
                                        .frame(height: 50)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .foregroundColor(.secondary.opacity(0.15))
                                                .opacity(selectedSymbol == symbol ? 1 : 0)
                                        )
                                }
                                .buttonStyle(RoundedRectangleButton())
                            }
                        }
                    } label: {
                        Text(category)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .navigationTitle("Symbols")
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private var searchResult: OrderedDictionary<String, [String]> {
        let lowercasedSearchText = searchText.lowercased()
        if lowercasedSearchText.isEmpty {
            return Symbols.symbols
        } else {
            var searchResult = OrderedDictionary<String, [String]>()
            for categorySymbolsPair in Symbols.symbols {
                let matchingSymbols = categorySymbolsPair.value
                    .filter{
                        $0.contains(lowercasedSearchText)
                    }
                if !matchingSymbols.isEmpty {
                    searchResult[categorySymbolsPair.key] = matchingSymbols
                }
            }
            return searchResult
        }
    }
}

struct RoundedRectangleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(.secondary.opacity(0.2))
                    .opacity(configuration.isPressed ? 1 : 0)
            )
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SymbolPicker_Previews: PreviewProvider {
    static var previews: some View {
        SymbolPicker(selectedSymbol: .constant("trash.slash.circle.fill"))
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
