import SwiftUI

struct LastBalanceAdjustmentOverlay: ViewModifier {
    @Binding var budget: Budget?
    
    func body(content: Content) -> some View {
        if let lastBalanceAdjustment = budget?.lastBalanceAdjustment {
            content
                .overlay(
                    Text("\(lastBalanceAdjustment.decimalValue.formatted(.eur().sign(strategy: .always())))")
                        .font(.system(size: 80, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Material.thin)
                        )
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.red.opacity(0.001))
                        .onTapGesture {
                            budget = nil
                        }
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
