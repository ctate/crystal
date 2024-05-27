import Foundation
import SwiftUI

struct WikipediaCard: View {
    var article: WikipediaArticleContent
    
    var body: some View {
        AdaptiveHeightView {
            VStack(spacing: 10) {
                if let imageURL = article.imageURL {
                    AsyncImage(url: imageURL) { imagePhase in
                        switch imagePhase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 300, maxHeight: 200)
                                .cornerRadius(10)
                        case .failure:
                            Text("Image not available")
                                .foregroundColor(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.bottom, 5)
                }
                
                Text(article.title)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.bottom, 5)
                
                Text(article.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
            }
        }
        .padding()
        .cornerRadius(10)
    }
}

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
        
        guard let article = try await WikipediaApi.fetchArticle(title: firstResultTitle) else {
            throw NSError(domain: "WikipediaTool", code: 0, userInfo: [NSLocalizedDescriptionKey: "No article found"])
        }
        
        let propsData = try JSONSerialization.data(withJSONObject: [
            "article": [
                "title": article.title,
                "content": article.content,
                "imageURL": article.imageURL?.absoluteString
            ]
        ])
        
        return ToolResponse(
            props: String(data: propsData, encoding: .utf8)!,
            text: "Search Wikipedia",
            view: AnyView(WikipediaCard(
                article: article
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
