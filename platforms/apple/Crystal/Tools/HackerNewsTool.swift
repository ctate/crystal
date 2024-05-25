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
    
    static func fetch(_ newMessage: Message, completion: @escaping (Result<ToolResponse, Error>) -> Void) {
        struct Response: Codable {
            let type: String
        }
        
        if let result = try? JSONDecoder().decode(Response.self, from: (newMessage.arguments ?? "{}").data(using: .utf8)!) {
            HackerNewsApi().getNewsIds(type: result.type) { result in
                HackerNewsApi().getArticleDetails(for: result) { result in
                    print(result)
                    
                    DispatchQueue.main.async {
                        completion(.success(ToolResponse(
                            props: String(data: try! JSONSerialization.data(withJSONObject: [
                                "articles": result,
                            ]), encoding: .utf8)!,
                            text:"Get Hacker News",
                            view: render(result)
                        )))
                    }
                }
            }
        }
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
