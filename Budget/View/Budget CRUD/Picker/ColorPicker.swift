import SwiftUI

struct ColorPicker: View {
    @Binding var selectedColor: BudgetColor
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Color")
                .font(.title2)
                .bold()
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 45), spacing: 10)], spacing: 10) {
                ForEach(BudgetColor.allCases, id: \.self) { color in
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
}

struct ColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColorPicker(selectedColor: .constant(.blue))
    }
}
