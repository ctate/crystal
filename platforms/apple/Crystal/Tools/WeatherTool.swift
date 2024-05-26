import CoreLocation
import Foundation
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

class WeatherTool {
    static let name = "get_current_weather"

    static let function = [
        "type": "function",
        "function": [
            "name": name,
            "description": "Get weather",
            "parameters": [
                "type": "object",
                "properties": [
                    "location": [
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA"
                    ]
                ],
                "required": [
                    "location"
                ]
            ]
        ]
    ] as [String : Any]
    
    static func fetch(_ newMessage: Message) async throws -> ToolResponse {
        let geocoder = CLGeocoder()
        
        struct Response: Codable {
            let location: String
        }
        
        guard let response = try? JSONDecoder().decode(Response.self, from: (newMessage.arguments ?? "{}").data(using: .utf8)!) else {
            throw NSError(domain: "WeatherToolError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode location"])
        }
        
        let placemarks = try await geocoder.geocodeAddressString(response.location)
        guard let placemark = placemarks.first, let location = placemark.location else {
            throw NSError(domain: "WeatherToolError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Geocoding failed"])
        }
        
        let (forecast, _, _) = try await WeatherAPI.getWeatherPoints(lat: "\(location.coordinate.latitude)", lng: "\(location.coordinate.longitude)")
        let (temperature, shortForecast) = try await WeatherAPI.getWeatherForecast(forecastUrl: forecast)
        
        let propsData = try JSONSerialization.data(withJSONObject: [
            "temperature": temperature,
            "forecast": shortForecast
        ])
        
        return ToolResponse(
            props: String(data: propsData, encoding: .utf8)!,
            text: "Get current weather",
            view: AnyView(WeatherCard(
                temperature: temperature,
                forecast: shortForecast
            ))
        )
    }
    
    static func render(_ message: Message) -> AnyView {
        struct Props: Codable {
            let temperature: Int
            let forecast: String
        }
        
        guard let result = try? JSONDecoder().decode(Props.self, from: (message.props ?? "{}").data(using: .utf8)!) else {
            return AnyView(TextCard(text: LocalizedStringKey("Unable to retrieve the weather")))
        }
        
        return AnyView(WeatherCard(
            temperature: result.temperature,
            forecast: result.forecast
        ))
    }
}
