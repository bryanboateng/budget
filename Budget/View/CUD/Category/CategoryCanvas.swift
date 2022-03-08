import SwiftUI

struct CategoryCanvas: View {
    @Binding var name: String
    @Binding var color: Category.Color
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Circle()
                    .foregroundColor(color.swiftUIColor)
                    .frame(width: 120, height: 120)
                TextField("Name", text: $name)
                    .font(.title)
                    .multilineTextAlignment(.center)
                Divider()
                ColorPicker(selectedColor: $color)
            }
            .padding(.top, 60)
            .padding(Edge.Set.all.subtracting(.top))
        }
    }
}
