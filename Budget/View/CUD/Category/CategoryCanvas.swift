import SwiftUI

struct CategoryCanvas: View {
	@Binding var name: String
	@Binding var color: Category.Color

	var body: some View {
		Form {
			Circle()
				.foregroundStyle(color.swiftUIColor)
				.frame(width: 100, height: 100)
				.frame(maxWidth: .infinity, alignment: .center)
				.listRowBackground(Color(UIColor.systemGroupedBackground))
			Section {
				Picker("Farbe", selection: $color) {
					ForEach(Category.Color.allCases, id: \.self) { color in
						Text({
							switch color {
							case .red: "Rot"
							case .orange: "Orange"
							case .yellow: "Gelb"
							case .green: "Grün"
							case .teal: "Türkis"
							case .blue: "Blau"
							case .purple: "Lila"
							case .pink: "Rosa"
							}
						}())
					}
				}
				.pickerStyle(.menu)
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
	@State var name = "Monatliche Ausgaben"
	@State var color = Category.Color.green
	return NavigationStack {
		CategoryCanvas(name: $name, color: $color)
	}
}
