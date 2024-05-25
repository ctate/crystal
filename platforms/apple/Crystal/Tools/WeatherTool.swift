import CoreLocation
import Foundation
import SwiftUI

struct WeatherData: Codable {
    let temperature: Int
    let forecast: String
}

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
    
    static func fetch(_ newMessage: Message, completion: @escaping (Result<ToolResponse, Error>) -> Void) {
        let geocoder = CLGeocoder()
        
        if let result = try? JSONDecoder().decode(OpenAIGetWeatherResponse.self, from: (newMessage.arguments ?? "{}").data(using: .utf8)!) {
            geocoder.geocodeAddressString(result.location) { (placemarks, error) in
                guard error == nil else {
                    print("Geocoding error: \(error!.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    let location = placemark.location
                    WeatherAPI().getWeatherPoints(
                        lat: "\(location?.coordinate.latitude ?? 0)",
                        lng: "\(location?.coordinate.longitude ?? 0)"
                    ) { forecast, forecastHourly, forecastGridData in
                        WeatherAPI().getWeatherForecast(forecastUrl: forecast) { temperature, shortForecast in
                            DispatchQueue.main.async {
                                completion(.success(ToolResponse(
                                    props: String(data: try! JSONSerialization.data(withJSONObject: [
                                        "temperature": temperature,
                                        "forecast": shortForecast
                                    ]), encoding: .utf8)!,
                                    text: "Get current weather",
                                    view: render(WeatherData(
                                        temperature: temperature,
                                        forecast: shortForecast
                                    ))
                                )))
                            }
                        }
                    }
                }
            }
        } else {
            print("Failed to decode location")
        }
    }
    
    static func render(_ message: Message) -> AnyView {
        guard let result = try? JSONDecoder().decode(WeatherData.self, from: (message.props ?? "{}").data(using: .utf8)!) else {
            return AnyView(TextCard(text: LocalizedStringKey("Unable to retrieve the weather")))
        }
        
        return AnyView(WeatherCard(
            temperature: result.temperature,
            forecast: result.forecast
        ))
    }
    
    static func render(_ data: WeatherData) -> AnyView {
        return AnyView(WeatherCard(
            temperature: data.temperature,
            forecast: data.forecast
        ))
    }
}
