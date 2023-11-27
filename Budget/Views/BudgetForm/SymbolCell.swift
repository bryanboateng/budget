import ComposableArchitecture
import SwiftUI

struct SymbolCell: View {
	let isSelected: Bool
	let symbol: String
	let color: Budget.Color

	var body: some View {
		VStack {
			ZStack {
				RoundedRectangle(cornerRadius: 12, style: .continuous)
					.strokeBorder(Color.accentColor, lineWidth: isSelected ? 4 : 0)
					.background(
						RoundedRectangle(
							cornerRadius: 12,
							style: .continuous
						)
						.foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
					)
					.aspectRatio(5 / 4, contentMode: .fill)
				Image(systemName: symbol)
					.foregroundStyle(color.swiftUIColor)
					.font(.system(size: 50))
			}
			Text(symbol)
				.font(.caption)
				.multilineTextAlignment(.center)
				.lineLimit(2, reservesSpace: true)
		}
	}
}

#Preview {
	SymbolCell(isSelected: false, symbol: "camera", color: .green)
}
