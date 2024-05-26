import Foundation

struct WikipediaSearchResult: Codable, Hashable {
    let title: String
    let snippet: String
    let link: String
}

struct WikipediaArticleContent: Codable, Hashable {
    let title: String
    let content: String
    let imageURL: URL?
}

class WikipediaApi {
    static func fetchSearchResults(query: String) async throws -> [WikipediaSearchResult] {
        let urlString = "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=\(query)&utf8=&format=json"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decodedResponse = try JSONDecoder().decode(WikipediaResponse.self, from: data)
        return decodedResponse.query.search.map { result in
            WikipediaSearchResult(title: result.title, snippet: result.snippet, link: "https://en.wikipedia.org/wiki/\(result.title.replacingOccurrences(of: " ", with: "_"))")
        }
    }
    
    static func fetchArticle(title: String) async throws -> WikipediaArticleContent? {
        let urlString = "https://en.wikipedia.org/w/api.php?action=query&prop=extracts|pageimages&exintro=&explaintext=&titles=\(title)&format=json&pithumbsize=500"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decodedResponse = try JSONDecoder().decode(WikipediaArticleResponse.self, from: data)
        if let page = decodedResponse.query.pages.values.first {
            return WikipediaArticleContent(
                title: page.title,
                content: page.extract,
                imageURL: page.thumbnail?.source
            )
        } else {
            return nil
        }
    }
}

struct WikipediaResponse: Codable {
    let query: Query
    struct Query: Codable {
        let search: [SearchInfo]
    }
    struct SearchInfo: Codable {
        let title: String
        let snippet: String
    }
}

struct WikipediaArticleResponse: Codable {
    let query: ArticleQuery
    struct ArticleQuery: Codable {
        let pages: [String: PageDetails]
    }
    struct PageDetails: Codable {
        let pageid: Int
        let title: String
        let extract: String
        let thumbnail: Thumbnail?
    }
    struct Thumbnail: Codable {
        let source: URL
    }
}
