//import SwiftUI
//
//struct BudgetCanvas: View {
//	@Binding var name: String
//	@Binding var symbol: String
//	@Binding var color: Budget.Color
//	@Binding var projectionIsEnabled: Bool
//	@Binding var monthlyAllocation: Decimal
//
//	var body: some View {
//		Form {
//			Section("Name") {
//				TextField("Name", text: $name, axis: .vertical)
//			}
//			Section("Symbol") {
//				Group {
//					if UIImage(systemName: symbol) != nil {
//						Image(systemName: symbol)
//					} else {
//						Image(systemName: "questionmark.diamond")
//							.foregroundStyle(.secondary)
//							.symbolVariant(.fill)
//					}
//				}
//				.foregroundStyle(color.swiftUIColor)
//				.font(.system(size: 100))
//				.frame(maxWidth: .infinity, alignment: .center)
//				TextField("Symbol", text: $symbol, axis: .vertical)
//					.autocorrectionDisabled(true)
//					.textInputAutocapitalization(.never)
//					.keyboardType(.asciiCapable)
//				Picker("Farbe", selection: $color) {
//					ForEach(Budget.Color.allCases, id: \.self) { color in
//						Text(color.localizedName)
//					}
//				}
//				.pickerStyle(.menu)
//			}
//			Section("Monatliche Zuweisung") {
//				Toggle("Monatliche Zuweisung", isOn: $projectionIsEnabled)
//				if projectionIsEnabled {
//					TextField(
//						"Monatliche Zuweisung",
//						value: $monthlyAllocation,
//						format: .number.precision(.fractionLength(2))
//					)
//					.keyboardType(.decimalPad)
//				}
//			}
//		}
//	}
//}
//
//#Preview {
//	@State var name = "Wasserflaschen"
//	@State var symbol = "waterbottle"
//	@State var color = Budget.Color.orange
//	@State var projectionIsEnabled = true
//	@State var monthlyAllocation = Decimal(234.85)
//	return NavigationStack {
//		BudgetCanvas(
//			name: $name,
//			symbol: $symbol,
//			color: $color,
//			projectionIsEnabled: $projectionIsEnabled,
//			monthlyAllocation: $monthlyAllocation
//		)
//	}
//}
