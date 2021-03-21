//
//  ColorPicker.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 21.03.21.
//

import SwiftUI


struct ColorPicker: View {
    @Binding var selectedColor: Budget.Color
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 45), spacing: 10)], spacing: 10) {
            ForEach(Budget.Color.allCases, id: \.self) { color in
                Circle()
                    .foregroundColor(color.swiftUIColor)
                    .aspectRatio(contentMode: .fill)
                    .onTapGesture {
                        self.selectedColor = color
                    }
                    .overlay(
                        Circle()
                            .strokeBorder(Color.secondary, lineWidth: 3)
                            .scaleEffect(1.27)
                            .opacity(selectedColor == color ? 1 : 0)
                    )
            }
        }
    }
}

struct ColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColorPicker(selectedColor: .constant(.blue))
    }
}
