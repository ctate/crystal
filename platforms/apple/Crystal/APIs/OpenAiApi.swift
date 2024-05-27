import Foundation

struct GeneratedImage: Codable, Hashable {
    let url: URL
}

struct OpenAIDalleResponse: Codable {
    struct Data: Codable {
        let url: URL
    }
    let data: [Data]
}

struct OpenAIResponse: Codable {
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

class OpenAiApi: ObservableObject {
    func generateImage(prompt: String) async throws -> [GeneratedImage] {
        guard let loadedData = load(KeychainKeys.Providers.OpenAI.apiKey),
              let apiKey = String(data: loadedData, encoding: .utf8) else {
            throw NSError(domain: "OpenAiApi", code: 1, userInfo: [NSLocalizedDescriptionKey: "API key loading failed"])
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "model": "dall-e-3",
            "quality": "standard",
            "n": 1,
            "size": "1024x1024"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "OpenAiApi", code: 2, userInfo: [NSLocalizedDescriptionKey: "Server responded with an error"])
        }
        
        let decodedResponse = try JSONDecoder().decode(OpenAIDalleResponse.self, from: data)
        return decodedResponse.data.map { GeneratedImage(url: $0.url) }
    }
    
    static func makeCompletions(model: String, messages: [[String: String]], tools: [[String: Any]]?) async throws -> OpenAIResponse {
        guard let loadedData = load(KeychainKeys.Providers.OpenAI.apiKey),
              let apiKey = String(data: loadedData, encoding: .utf8) else {
            throw NSError(domain: "OpenAiApi", code: 1, userInfo: [NSLocalizedDescriptionKey: "API key loading failed"])
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var requestBody: [String: Any] = ["model": model, "messages": messages]
        if let toolsData = tools {
            requestBody["tools"] = toolsData
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "OpenAiApi", code: 2, userInfo: [NSLocalizedDescriptionKey: "Server responded with an error"])
        }
        
        return try JSONDecoder().decode(OpenAIResponse.self, from: data)
    }
}
