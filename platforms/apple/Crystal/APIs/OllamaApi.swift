import Foundation

struct OllamaContent: Codable {
    struct Function: Codable {
        let name: String
        let arguments: String
    }
    let type: String
    let function: Function
}

struct OllamaResponse: Codable {
    struct Message: Codable {
        let role: String
        let content: String
    }
    let model: String
    let message: Message
    let prompt_eval_count: Int
    let eval_count: Int
}

class OllamaApi: ObservableObject {
    func makeCompletions(model: String, messages: [[String: String]], tools: [[String: Any]]?, completion: @escaping (OllamaResponse, OllamaContent?) -> Void) {
        guard let host = UserDefaults.standard.string(forKey: "Ollama:host") else {
            alertError("Host not configured")
            return
        }
        
        guard let url = URL(string: host) else {
            alertError("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var requestMessages = messages
        if !requestMessages.isEmpty && tools != nil {
            requestMessages[requestMessages.count - 1] = [
                "role": requestMessages[requestMessages.count - 1]["role"]!,
                "content": """
                    You are an AI assistant that supports function calling. You only respond with JSON.

                    When the user sends you a prompt, look through these Available Functions and choose the best match:

                    \(String(data: try! JSONSerialization.data(withJSONObject: tools!), encoding: .utf8)! )
                
                    Each function has "parameters" written as a JSON Schema.

                    If there is a match, you should ONLY respond with JSON like the example below that corresponds with the function name and its arguments (an escaped JSON string) based on its parameters (JSON Schema):

                    {
                      "type": "function",
                      "function": {
                        "name": "get_current_weather",
                        "arguments": "{\"location\":\"Austin, TX\"}"
                      }
                    }
                
                    If there is NO good match, answer the user's prompt like the example below:
                
                    {
                      "type": "function",
                      "function": {
                        "name": "text",
                        "arguments": "{\"text\":\"[your response goes here]\"}"
                      }
                    }
                
                    The user prompt is: \(requestMessages[requestMessages.count - 1]["content"]!)
                """
            ]
        }
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": requestMessages,
            "stream": false
        ]
        
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
            
            guard let result = try? JSONDecoder().decode(OllamaResponse.self, from: data) else {
                alertError("Failed to decode response")
                return
            }
            
            guard let content = try? JSONDecoder().decode(OllamaContent.self, from: result.message.content.data(using: .utf8)!) else {
                print("Failed to decode content")
                DispatchQueue.main.async {
                    completion(result, nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(result, content)
            }
        }
        
        task.resume()
    }
}
