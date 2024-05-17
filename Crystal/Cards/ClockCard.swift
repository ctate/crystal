import SwiftUI

struct ClockCard: View {
    var body: some View {
        Text("Current time: 12:00pm")
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
