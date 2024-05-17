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
    func makeCompletions(model: String, messages: [[String: String]], tools: [[String: Any]]?, completion: @escaping (AnthropicResponse) -> Void) {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            print("Invalid URL")
            return
        }
        
        guard let loadedData = load(key: "\(bundleIdentifier).AnthropicApiKey") else { return }
        guard let apiKey = String(data: loadedData, encoding: .utf8) else { return }
        
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
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                alertError(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                alertError("Invalid data")
                return
            }
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response: \(rawResponse)")
            }
            
            guard let response = response as? HTTPURLResponse else {
                alertError("Invalid response")
                return
            }
            
            guard response.statusCode == 200 else {
                alertError("Invalid response")
                return
            }
            
            if let result = try? JSONDecoder().decode(AnthropicResponse.self, from: data) {
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
