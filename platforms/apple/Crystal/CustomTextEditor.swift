import SwiftUI

struct CustomTextEditor: View {
    @Binding var text: String
    
    @State private var textHeight: CGFloat = 16  // Explicitly set initial height to 30
    
    var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    Text("\(text)")
                        .foregroundColor(.clear)
                        .frame(width: geometry.size.width * 0.99, alignment: .leading)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onChange(of: text) {
                                        var calcHeight = geometry.size.height
                                        if calcHeight > 100 {
                                            calcHeight = 100
                                        } else if calcHeight < 16 {
                                            calcHeight = 16
                                        }
                                        textHeight = calcHeight
                                    }
                            }
                        )
                        .padding(.leading, 5)
                    TextEditor(text: $text)
                        .font(.body)
                        .frame(width:  geometry.size.width * 0.99, height: textHeight)
                        .cornerRadius(10)
                        .scrollDisabled(textHeight < 100)
                }
                
            }
            .frame(maxHeight: textHeight + 16)
            .padding(.bottom, -16)
        
    }
}

#Preview {
    CustomTextEditor(text: .constant(""))
}
