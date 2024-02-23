import SwiftUI

struct CirclebadgeLabel<S: StringProtocol>: View {
	let title: S
	let color: Account.Budget.Color

	init(_ title: S, color: Account.Budget.Color) {
		self.title = title
		self.color = color
	}

	var body: some View {
		// We use an HStack instead of a SwiftUI Label
		// because inside of lists the image takes up
		// too much width
		HStack {
			Image(systemName: "circlebadge")
				.foregroundStyle(color.swiftUIColor)
				.symbolVariant(.fill)
				.imageScale(.small)
			Text(title)
		}
	}
}

#Preview {
	return NavigationStack {
		List(0..<100) { _ in
			CirclebadgeLabel("Moinsen", color: .red)
			CirclebadgeLabel("Moinsen", color: .green)
		}
	}
}
