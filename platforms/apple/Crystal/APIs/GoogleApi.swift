import Foundation

struct SearchResult: Codable, Hashable {
    let title: String
    let snippet: String
    let link: String
}

class GoogleApi {
    func fetchSearchResults(query: String, completion: @escaping ([SearchResult]) -> Void) {
        guard let loadedDataApiKey = load(key: "\(bundleIdentifier).GoogleApiKey") else { return }
        guard let loadedDataSearchEngineId = load(key: "\(bundleIdentifier).GoogleSearchEngineId") else { return }
        
        guard let apiKey = String(data: loadedDataApiKey, encoding: .utf8) else { return }
        guard let searchEngineId = String(data: loadedDataSearchEngineId, encoding: .utf8) else { return }
        
        print("https://www.googleapis.com/customsearch/v1?q=\(query)&key=\(apiKey)&cx=\(searchEngineId)")
        
        guard let url = URL(string: "https://www.googleapis.com/customsearch/v1?q=\(query)&key=\(apiKey)&cx=\(searchEngineId)") else {
            alertError("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let decodedResponse = try? JSONDecoder().decode(GoogleResponse.self, from: data) {
                DispatchQueue.main.async {
                    completion(decodedResponse.items)
                }
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
}

struct GoogleResponse: Codable {
    let items: [SearchResult]
}
