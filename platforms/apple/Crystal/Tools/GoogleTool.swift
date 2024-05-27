import Foundation
import SwiftUI

struct GoogleSearchCardView: View {
    let result: SearchResult
    
    var body: some View {
        AdaptiveHeightView {
            VStack(alignment: .leading, spacing: 10) {
                Text(result.title)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        openLink(urlString: result.link)
                    }
                
                Text(result.snippet)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(result.link)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding()
        }
    }
}

struct GoogleSearchCard: View {
    var results: [SearchResult]
    
    var body: some View {
        List {
            ForEach(results, id: \.self) { result in
                GoogleSearchCardView(result: result)
            }
        }
    }
}

class GoogleTool {
    static let name = "search_web"
    
    static let function = [
        "type": "function",
        "function": [
            "name": name,
            "description": "Search web",
            "parameters": [
                "type": "object",
                "properties": [
                    "query": [
                        "type": "string"
                    ]
                ],
                "required": [
                    "query"
                ]
            ]
        ]
    ] as [String : Any]
    
    static func fetch(_ newMessage: Message) async throws -> ToolResponse {
        struct Response: Codable {
            let query: String
        }
        
        guard let result = try? JSONDecoder().decode(Response.self, from: (newMessage.arguments ?? "{}").data(using: .utf8)!) else {
            throw NSError(domain: "GoogleTool", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode query"])
        }
        
        guard let results = try? await GoogleApi().fetchSearchResults(query: result.query) else {
            throw NSError(domain: "GoogleTool", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to find results"])
        }
        
        let propsData = try JSONSerialization.data(withJSONObject: [
            "results": results.map {
                [
                    "title": $0.title,
                    "link": $0.link,
                    "snippet": $0.snippet
                ]
            }
        ])
        
        return ToolResponse(
            props: String(data: propsData, encoding: .utf8)!,
            text: "Search web",
            view: AnyView(GoogleSearchCard(
                results: results
            ))
        )
    }
    
    static func render(_ message: Message) -> AnyView {
        struct Props: Codable {
            let results: [SearchResult]
        }
        
        guard let result = try? JSONDecoder().decode(Props.self, from: (message.props ?? "{}").data(using: .utf8)!) else {
            return AnyView(TextCard(text: LocalizedStringKey("Failed")))
        }
        
        return AnyView(GoogleSearchCard(results: result.results))
    }
}
