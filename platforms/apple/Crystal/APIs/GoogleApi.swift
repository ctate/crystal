import Foundation

struct SearchResult: Codable, Hashable {
    let title: String
    let snippet: String
    let link: String
}

class GoogleApi {
    func fetchSearchResults(query: String) async throws -> [SearchResult] {
        guard let loadedDataApiKey = load(KeychainKeys.Integrations.Google.apiKey),
              let loadedDataSearchEngineId = load(KeychainKeys.Integrations.Google.searchEngineId),
              let apiKey = String(data: loadedDataApiKey, encoding: .utf8),
              let searchEngineId = String(data: loadedDataSearchEngineId, encoding: .utf8) else {
            throw GoogleApiError.missingCredentials
        }
        
        let urlString = "https://www.googleapis.com/customsearch/v1?q=\(query)&key=\(apiKey)&cx=\(searchEngineId)"
        guard let url = URL(string: urlString) else {
            throw GoogleApiError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw GoogleApiError.badResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let decodedResponse = try JSONDecoder().decode(GoogleResponse.self, from: data)
        return decodedResponse.items
    }
}

enum GoogleApiError: Error {
    case missingCredentials
    case invalidURL
    case badResponse(statusCode: Int)
}

struct GoogleResponse: Codable {
    let items: [SearchResult]
}
