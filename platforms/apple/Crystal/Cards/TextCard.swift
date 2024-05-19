import SwiftUI

struct TextCard: View {
    var text: LocalizedStringKey

    var body: some View {
        AdaptiveHeightView {
            Text(text)
                .font(.system(size: 18))
                .padding(.horizontal, 20)
                .foregroundColor(.white)
                .textSelection(.enabled)
        }
    }
}
