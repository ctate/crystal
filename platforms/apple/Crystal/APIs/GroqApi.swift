import Foundation

struct GroqDalleResponse: Codable {
    struct Data: Codable {
        let url: URL
    }
    let data: [Data]
}

struct GroqResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            struct ToolCall: Codable {
                let id: String
                let type: String
                let function: FunctionDetail
            }
            struct FunctionDetail: Codable {
                let name: String
                let arguments: String
            }
            let role: String
            let content: String?
            let tool_calls: [ToolCall]?
        }
        let message: Message
    }
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
}

class GroqApi: ObservableObject {
    static func makeCompletions(model: String, messages: [[String: String]], tools: [[String: Any]]?) async throws -> GroqResponse {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        guard let loadedData = load(key: "\(bundleIdentifier).GroqApiKey"),
              let apiKey = String(data: loadedData, encoding: .utf8) else {
            throw NSError(domain: "GroqApi", code: 1, userInfo: [NSLocalizedDescriptionKey: "API key loading failed"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
        ]
        if let tools = tools {
            requestBody["tools"] = tools
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "GroqApi", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(GroqResponse.self, from: data)
    }
}
