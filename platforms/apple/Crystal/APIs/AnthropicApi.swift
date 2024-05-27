import Foundation

struct AnthropicResponse: Codable {
    struct Content: Codable {
        let type: String
        let text: String?
        let name: String?
        let input: [String: String]?
    }
    let id: String
    let type: String
    let role: String
    let model: String
    let content: [Content]
    let stopReason: String?
}


class AnthropicApi: ObservableObject {
    static func makeCompletions(model: String, messages: [[String: String]], tools: [[String: Any]]?) async throws -> AnthropicResponse {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        guard let loadedData = load(KeychainKeys.Providers.Anthropic.apiKey) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "API key not found"])
        }
        
        guard let apiKey = String(data: loadedData, encoding: .utf8) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode API key"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("tools-2024-04-04", forHTTPHeaderField: "anthropic-beta")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var requestBody: [String: Any] = [
            "model": model,
            "messages": messages.filter { $0["role"] != "system" },
            "max_tokens": 1024
        ]
        if tools != nil {
            requestBody["tools"] = encodeFunctions(functions: parseFunctions(from: tools!))
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "HTTP request failed with response: \(response)"])
        }
        
        return try JSONDecoder().decode(AnthropicResponse.self, from: data)
    }
}
