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
    func makeCompletions(model: String, messages: [[String: String]], tools: [[String: Any]]?, completion: @escaping (GroqResponse) -> Void) {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            print("Invalid URL")
            return
        }
        
        guard let loadedData = load(key: "\(bundleIdentifier).GroqApiKey") else { return }
        guard let apiKey = String(data: loadedData, encoding: .utf8) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
        ]
        if tools != nil {
            requestBody["tools"] = tools
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                alertError(error.localizedDescription)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                alertError("Invalid response or data")
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response: \(rawResponse)")
            }
            
            if let result = try? JSONDecoder().decode(GroqResponse.self, from: data) {
                DispatchQueue.main.async {
                    completion(result)
                }
            } else {
                alertError("Failed to decode response")
            }
        }
        
        task.resume()
    }
}
