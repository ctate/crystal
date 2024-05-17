import Foundation

struct OllamaResponse: Codable {
    struct Message: Codable {
        let role: String
        let content: String
    }
    let model: String
    let message: Message
}

class OllamaApi: ObservableObject {
    func makeCompletions(messages: [[String: String]], tools: [[String: Any]]?, completion: @escaping (OllamaResponse) -> Void) {
        guard let url = URL(string: "http://192.168.68.115:11434/api/chat") else {
            alertError("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var requestBody: [String: Any] = [
            "model": "llama3",
            "messages": messages,
            "stream": false
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
            
            if let result = try? JSONDecoder().decode(OllamaResponse.self, from: data) {
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
