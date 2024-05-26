import Foundation
import SwiftUI

class WikipediaTool {
    static let name = "search_wikipedia"
    
    static let function = [
        "type": "function",
        "function": [
            "name": name,
            "description": "Search Wikipedia for biography",
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
            throw NSError(domain: "WikipediaTool", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode query"])
        }
        
        let searchResults = try await WikipediaApi.fetchSearchResults(query: result.query)
        guard let firstResultTitle = searchResults.first?.title else {
            throw NSError(domain: "WikipediaTool", code: 0, userInfo: [NSLocalizedDescriptionKey: "No results found"])
                    }
        
        let article = try await WikipediaApi.fetchArticle(title: firstResultTitle)
        
        let propsData = try JSONSerialization.data(withJSONObject: [
            "article": article
        ])
        
        return ToolResponse(
            props: String(data: propsData, encoding: .utf8)!,
            text: "Search Wikipedia",
            view: AnyView(WikipediaCard(
                article: article!
            ))
        )
    }
    
    static func render(_ message: Message) -> AnyView {
        struct Props: Codable {
            let article: WikipediaArticleContent
        }
        
        guard let result = try? JSONDecoder().decode(Props.self, from: (message.props ?? "{}").data(using: .utf8)!) else {
            return AnyView(TextCard(text: LocalizedStringKey("Failed")))
        }
        
        return AnyView(WikipediaCard(article: result.article))
    }
}
