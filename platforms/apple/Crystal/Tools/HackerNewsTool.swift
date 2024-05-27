import Foundation
import SwiftUI

struct ToolResponse {
    let props: String
    let text: String
    let view: AnyView
}

struct HackerNewsCard: View {
    var articles: [ArticleDetail]
    
    var body: some View {
        NavigationView {
            List(articles, id: \.url) { article in
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let description = article.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                    }
                    Spacer()
                    if let imageUrl = article.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            case .failure(_):
                                EmptyView()
                            default:
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
    }
}

class HackerNewsTool {
    static let name = "get_hacker_news"
    
    static let function = [
        "type": "function",
        "function": [
            "name": name,
            "description": "Get Hacker News",
            "parameters": [
                "type": "object",
                "properties": [
                    "type": [
                        "type": "string",
                        "enum": ["top", "new", "best"],
                        "description": "type of news stories",
                        "default": "top"
                    ]
                ],
                "required": [
                    "type"
                ]
            ]
        ]
    ] as [String: Any]
    
    static func fetch(_ newMessage: Message) async throws -> ToolResponse {
        struct Response: Codable {
            let type: String
        }
        
        guard let result = try? JSONDecoder().decode(Response.self, from: (newMessage.arguments ?? "{}").data(using: .utf8)!) else {
            throw NSError(domain: "HackerNewsCard", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode type"])
        }
        
        guard let ids = try? await HackerNewsApi().getNewsIds(type: result.type) else {
            throw NSError(domain: "HackerNewsCard", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get news ids"])
        }
        
        guard let articles = try? await HackerNewsApi().getArticleDetails(for: ids) else {
            throw NSError(domain: "HackerNewsCard", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get news articles"])
        }
        
        let propsData = try JSONSerialization.data(withJSONObject: [
            "articles": articles.map {
                [
                    "title": $0.title,
                    "url": $0.url,
                    "description": $0.description,
                    "image": $0.image
                ]
            }
        ])
        
        return ToolResponse(
            props: String(data: propsData, encoding: .utf8)!,
            text: "Search Wikipedia",
            view: AnyView(HackerNewsCard(
                articles: articles
            ))
        )
    }
    
    static func render(_ message: Message) -> AnyView {
        struct Props: Codable {
            let articles: [ArticleDetail]
        }
        
        guard let result = try? JSONDecoder().decode(Props.self, from: (message.props ?? "{}").data(using: .utf8)!) else {
            return AnyView(TextCard(text: LocalizedStringKey("Failed")))
        }
        
        return AnyView(HackerNewsCard(articles: result.articles))
    }
    
    static func render(_ data: [ArticleDetail]) -> AnyView {
        return AnyView(HackerNewsCard(
            articles: data
        ))
    }
}
