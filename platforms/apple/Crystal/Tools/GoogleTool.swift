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
