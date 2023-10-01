import SwiftUI

struct BudgetCanvas: View {
	@Binding var name: String
	@Binding var symbol: String
	@Binding var showGreeting: Bool
	@Binding var grenze: Decimal
	@Binding var color: Budget.Color

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
					.autocorrectionDisabled(true)
					.textInputAutocapitalization(.never)
				Picker("Farbe", selection: $color) {
					ForEach(Budget.Color.allCases, id: \.self) { color in
						Text(color.localizedName)
					}
				}
				.pickerStyle(.menu)
			} header: {
				Text("Symbol")
			}
			Section {
				TextField("Name", text: $name, axis: .vertical)
			} header: {
				Text("Name")
			}
			Section {
				Toggle("Monatliche Zuweisung", isOn: $showGreeting)
				if showGreeting {
					TextField(
						"Monatliche Zuweisung",
						value: $grenze,
						format: .number.precision(.fractionLength(2))
					)
					.keyboardType(.decimalPad)
				}
			} header: {
				Text("Monatliche Zuweisung")
			}
		}
	}
}

#Preview {
	@State var name = "Wasserflaschen"
	@State var symbol = "waterbottle"
	@State var showGreeting = true
	@State var grenze = Decimal(234.85)
	@State var color = Budget.Color.orange
	return NavigationStack {
		BudgetCanvas(
			name: $name,
			symbol: $symbol,
			showGreeting: $showGreeting,
			grenze: $grenze,
			color: $color
		)
	}
}
