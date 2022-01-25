import SwiftUI

struct BudgetCanvas: View {
    @Binding var name: String
    @Binding var color: BudgetColor
    @Binding var symbol: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Image(systemName: symbol)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(color.swiftUIColor)
                    .font(.system(size: 120))
                TextField("Name", text: $name)
                    .font(.title)
                    .multilineTextAlignment(.center)
                Divider()
                ColorPicker(selectedColor: $color)
                Divider()
                SymbolPicker(selectedSymbol: $symbol)
            }
            .padding(.top, 60)
            .padding(Edge.Set.all.subtracting(.top))
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image(systemName: symbol)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(color.swiftUIColor)
            }
        }
    }
}
