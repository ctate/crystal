import SwiftUI

struct WeatherCard: View {
    var temperature: Int
    var forecast: String
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("\(temperature)")
                    .font(.system(size: 72))
                    .foregroundColor(.white)
                
                Text("°F")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }
            
            Text(forecast)
                .padding(.horizontal, 20)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}
