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
    func generateImage(prompt: String, completion: @escaping ([GeneratedImage]) -> Void) {
        guard let loadedData = load(key: "\(bundleIdentifier).OpenAIApiKey") else { return }
        guard let apiKey = String(data: loadedData, encoding: .utf8) else { return }
        
        let url = URL(string: "https://api.openai.com/v1/images/generations")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String : Any] = ["prompt": prompt, "model": "dall-e-3", "quality": "standard", "n": 1, "size": "1024x1024"]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw response: \(rawResponse)")
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(OpenAIDalleResponse.self, from: data)
                    let images = decodedResponse.data.map { GeneratedImage(url: $0.url) }
                    DispatchQueue.main.async {
                        completion(images)
                    }
                } catch {
                    print("Decode failed: \(error.localizedDescription)")
                }
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    func makeCompletions(model: String, messages: [[String: String]], tools: [[String: Any]]?, completion: @escaping (OpenAIResponse) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            alertError("Invalid URL")
            return
        }
        
        guard let loadedData = load(key: "\(bundleIdentifier).OpenAIApiKey") else {
            alertError("No API key found")
            return
        }
        guard let apiKey = String(data: loadedData, encoding: .utf8) else {
            alertError("Failed to load API key")
            return
        }
        
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
            
            guard let data = data else {
                alertError("Invalid data")
                return
            }
            
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response: \(rawResponse)")
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                alertError("Invalid response")
                return
            }
            
            if let result = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
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
