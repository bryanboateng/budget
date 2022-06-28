import SwiftUI

struct BudgetCanvas: View {
	@Binding var name: String
	@Binding var symbol: String
	let color: Category.Color

	var body: some View {
		Form {
			Section {
				TextField("Name", text: $name)
				TextField("Symbol", text: $symbol)
			}
		}
	}
}
