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
