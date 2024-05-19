import SwiftUI

struct ForceDarkMode: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, .dark)
    }
}

extension View {
    func forceDarkMode() -> some View {
        self.modifier(ForceDarkMode())
    }
}
