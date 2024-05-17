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
    func getWeatherForecast(forecastUrl: String, completion: @escaping (Int, String) -> Void) {
        guard let url = URL(string: forecastUrl) else {
            alertError("Invalid URL")
            return
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "GET"

        print(url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                alertError(error.localizedDescription)
                return
            }

            guard let data = data else {
                alertError("No data received")
                return
            }
                        
            do {
                let weatherForecastResponse = try JSONDecoder().decode(WeatherForecastResponse.self, from: data)
                
                print(weatherForecastResponse)
                
                completion(weatherForecastResponse.properties.periods.first?.temperature ?? 0, weatherForecastResponse.properties.periods.first?.shortForecast ?? "")
            } catch {
                alertError("Error parsing JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    func getWeatherPoints(lat: String, lng: String, completion: @escaping (String, String, String) -> Void) {
        print("https://api.weather.gov/points/\(lat),\(lng)")
        guard let url = URL(string: "https://api.weather.gov/points/\(lat),\(lng)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let weatherPointsResponse = try JSONDecoder().decode(WeatherPointsResponse.self, from: data)
                completion(weatherPointsResponse.properties.forecast, weatherPointsResponse.properties.forecastHourly, weatherPointsResponse.properties.forecastGridData)
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
}
