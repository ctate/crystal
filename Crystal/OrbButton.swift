import SwiftUI

struct OrbButton: View {
    @Binding var animate: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 10)
                        .scaleEffect(animate ? 1.0 : 0.9)
                        .opacity(animate ? 0.0 : 1.0)
                        .animation(animate ? Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) : nil, value: animate)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 10)
                        .scaleEffect(animate ? 1.5 : 1.4)
                        .opacity(animate ? 0.0 : 0.3)
                        .animation(animate ? Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.2) : nil, value: animate)
                )
            
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .shadow(radius: 10)
        }
    }
}
