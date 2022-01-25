import SwiftUI

struct SymbolPicker: View {
    @Binding var selectedSymbol: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Symbol")
                .font(.title2)
                .bold()
            ForEach(Symbols.symbols.keys, id: \.self) { category in
                VStack(alignment: .leading) {
                    Text(category)
                        .font(.headline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 45), spacing: 10)], spacing: 10) {
                        ForEach(Symbols.symbols[category]!, id: \.self) { symbol in
                            Image(systemName: symbol)
                                .resizable()
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.secondary)
                                .aspectRatio(contentMode: .fill)
                                .onTapGesture {
                                    self.selectedSymbol = symbol
                                }
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.secondary, lineWidth: 3)
                                        .scaleEffect(1.27)
                                        .opacity(selectedSymbol == symbol ? 1 : 0)
                                )
                        }
                    }
                }
            }
        }
    }
}

struct SymbolPicker_Previews: PreviewProvider {
    static var previews: some View {
        SymbolPicker(selectedSymbol: .constant("trash.slash.circle.fill"))
            .previewLayout(.sizeThatFits)
    }
}
