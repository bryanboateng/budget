import SwiftUI

struct BudgetCanvas: View {
	@Binding var name: String
	@Binding var symbol: String
	let color: Category.Color

	var body: some View {
		Form {
			Label(name, systemImage: symbol)
				.foregroundStyle(color.swiftUIColor)
				.font(.system(size: 100))
				.labelStyle(.iconOnly)
				.frame(maxWidth: .infinity, alignment: .center)
				.listRowBackground(Color(UIColor.systemGroupedBackground))
			Section {
				TextField("Symbol", text: $symbol, axis: .vertical)
			} header: {
				Text("Symbol")
			}
			Section {
				TextField("Name", text: $name, axis: .vertical)
			} header: {
				Text("Name")
			}
		}
	}
}

#Preview {
	@State var name = "Wasserflaschen"
	@State var symbol = "waterbottle"
	return NavigationStack {
		BudgetCanvas(name: $name, symbol: $symbol, color: .green)
	}
}
