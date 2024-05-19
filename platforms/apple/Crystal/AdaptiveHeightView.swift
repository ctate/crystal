import SwiftUI

struct AdaptiveHeightView<Content: View>: View {
    @State private var contentHeight: CGFloat = .zero
    @State private var frameHeight: CGFloat = .zero
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if contentHeight <= geometry.size.height {
                    Spacer()
                    content()
                        .frame(width: geometry.size.width)
                        .background(GeometryReader { geo in
                            Color.clear.preference(key: ViewHeightKey.self, value: geo.size.height)
                        })
                    Spacer()
                } else {
                    ScrollView {
                        content()
                            .frame(width: geometry.size.width)
                            .background(GeometryReader { geo in
                                Color.clear.preference(key: ViewHeightKey.self, value: geo.size.height)
                            })
                    }
                }
            }
            .onPreferenceChange(ViewHeightKey.self) { height in
                contentHeight = height
            }
            .frame(height: geometry.size.height, alignment: .top)
        }
    }
}

// Preference key to communicate the height of the content
struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
