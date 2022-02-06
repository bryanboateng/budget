import SwiftUI

struct LastBalanceAdjustmentOverlay: ViewModifier {
    @Binding var budget: Budget?
    
    func body(content: Content) -> some View {
        if let lastBalanceAdjustment = budget?.lastBalanceAdjustment {
            content
                .onTapGesture {
                    budget = nil
                }
                .onLongPressGesture {
                    budget = nil
                }
                .overlay(
                    Text("\(lastBalanceAdjustment.decimalValue.formatted(.eur().sign(strategy: .always())))")
                        .font(.system(size: 80, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Material.thin)
                        .colorScheme(.dark)
                )
        } else {
            content
        }
    }
}

extension View {
    func lastBalanceAdjustmentOverlay(budget: Binding<Budget?>) -> some View {
        modifier(LastBalanceAdjustmentOverlay(budget: budget))
    }
}
