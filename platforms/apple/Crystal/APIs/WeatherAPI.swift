import Foundation

struct WeatherForecastResponse: Codable {
    struct Properties: Codable {
        struct Period: Codable {
            let name: String
            let temperature: Int
            let windSpeed: String
            let windDirection: String
            let shortForecast: String
        }
        let periods: [Period]
    }
    let properties: Properties
}

struct WeatherPointsResponse: Codable {
    struct Properties: Codable {
        let forecast: String
        let forecastHourly: String
        let forecastGridData: String
    }
    let properties: Properties
}

class WeatherAPI: ObservableObject {
    static func getWeatherForecast(forecastUrl: String) async throws -> (Int, String) {
        guard let url = URL(string: forecastUrl) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let weatherForecastResponse = try JSONDecoder().decode(WeatherForecastResponse.self, from: data)
        return (weatherForecastResponse.properties.periods.first?.temperature ?? 0, weatherForecastResponse.properties.periods.first?.shortForecast ?? "")
    }
    
    static func getWeatherPoints(lat: String, lng: String) async throws -> (String, String, String) {
        guard let url = URL(string: "https://api.weather.gov/points/\(lat),\(lng)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let weatherPointsResponse = try JSONDecoder().decode(WeatherPointsResponse.self, from: data)
        return (weatherPointsResponse.properties.forecast, weatherPointsResponse.properties.forecastHourly, weatherPointsResponse.properties.forecastGridData)
    }
}
