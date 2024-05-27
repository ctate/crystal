import Foundation
import SwiftSoup

struct ArticleDetail: Codable {
    let title: String
    let url: String
    var description: String?
    var image: String?
}

class HackerNewsApi: ObservableObject {
    func getNewsIds(type: String) async throws -> [Int] {
        guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/\(type)stories.json") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Int].self, from: data)
    }
    
    func getArticleDetails(for ids: [Int]) async -> [ArticleDetail] {
        let articles = await withTaskGroup(of: ArticleDetail?.self, returning: [ArticleDetail].self) { group in
            for id in ids.prefix(10) {
                group.addTask {
                    do {
                        return try await self.fetchArticleDetail(for: id)
                    } catch {
                        print("Error fetching details for article \(id): \(error)")
                        return nil
                    }
                }
            }
            
            var articles: [ArticleDetail] = []
            for await article in group {
                if let article = article {
                    articles.append(article)
                }
            }
            
            return articles
        }
        return articles
    }
    
    private func fetchArticleDetail(for id: Int) async throws -> ArticleDetail {
        guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        var articleDetail = try JSONDecoder().decode(ArticleDetail.self, from: data)
        
        if let articleURL = URL(string: articleDetail.url) {
            let htmlData = try await URLSession.shared.data(from: articleURL).0
            let html = String(decoding: htmlData, as: UTF8.self)
            let doc = try SwiftSoup.parse(html)
            let description = try doc.select("meta[property=og:description]").first()?.attr("content")
            var image = try doc.select("meta[property=og:image]").first()?.attr("content")
            
            if let img = image, !img.starts(with: "http") {
                image = articleURL.absoluteString + img
            }
            
            articleDetail.description = description
            articleDetail.image = image
        }
        
        return articleDetail
    }
}
