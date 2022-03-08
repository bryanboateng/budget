import SwiftUI

struct BudgetCanvas: View {
    @State private var isPickingSymbol = false

    @Binding var name: String
    @Binding var symbol: String
    let color: Category.Color

    var body: some View {
        Form {
            Button {
                isPickingSymbol = true
            } label: {
                Image(systemName: symbol)
                    .foregroundColor(color.swiftUIColor)
                    .font(.system(size: 70))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            Section {
                TextField("Name", text: $name)
            }
        }
        .fullScreenCover(isPresented: $isPickingSymbol) {
            SymbolPicker(selectedSymbol: $symbol)
        }
    }
}
