import SwiftUI

struct BudgetCanvas: View {
	@Binding var name: String
	@Binding var symbol: String
	@Binding var color: Budget.Color
	@Binding var projectionIsEnabled: Bool
	@Binding var monthlyAllocation: Decimal

	var body: some View {
		Form {
			Label(name, systemImage: symbol)
				.foregroundStyle(color.swiftUIColor)
				.font(.system(size: 100))
				.labelStyle(.iconOnly)
				.frame(maxWidth: .infinity, alignment: .center)
				.listRowBackground(Color(UIColor.systemGroupedBackground))
			Section {
				TextField("Name", text: $name, axis: .vertical)
			} header: {
				Text("Name")
			}
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
				Toggle("Monatliche Zuweisung", isOn: $projectionIsEnabled)
				if projectionIsEnabled {
					TextField(
						"Monatliche Zuweisung",
						value: $monthlyAllocation,
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
	@State var color = Budget.Color.orange
	@State var projectionIsEnabled = true
	@State var monthlyAllocation = Decimal(234.85)
	return NavigationStack {
		BudgetCanvas(
			name: $name,
			symbol: $symbol,
			color: $color,
			projectionIsEnabled: $projectionIsEnabled,
			monthlyAllocation: $monthlyAllocation
		)
	}
}
