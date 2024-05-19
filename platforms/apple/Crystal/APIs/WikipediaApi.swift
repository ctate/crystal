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
    func fetchSearchResults(query: String, completion: @escaping ([WikipediaSearchResult]) -> Void) {
        let urlString = "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=\(query)&utf8=&format=json"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            alertError("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(WikipediaResponse.self, from: data)
                    let results = decodedResponse.query.search.map { result in
                        WikipediaSearchResult(title: result.title, snippet: result.snippet, link: "https://en.wikipedia.org/wiki/\(result.title.replacingOccurrences(of: " ", with: "_"))")
                    }
                    DispatchQueue.main.async {
                        completion(results)
                    }
                } catch {
                    alertError("Decode failed: \(error.localizedDescription)")
                }
            } else {
                alertError("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    func fetchArticle(title: String, completion: @escaping (WikipediaArticleContent?) -> Void) {
        let urlString = "https://en.wikipedia.org/w/api.php?action=query&prop=extracts|pageimages&exintro=&explaintext=&titles=\(title)&format=json&pithumbsize=500"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(WikipediaArticleResponse.self, from: data)
                    if let page = decodedResponse.query.pages.values.first {
                        let article = WikipediaArticleContent(
                            title: page.title,
                            content: page.extract,
                            imageURL: page.thumbnail?.source
                        )
                        DispatchQueue.main.async {
                            completion(article)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } catch {
                    print("Decode failed: \(error.localizedDescription)")
                }
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
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
