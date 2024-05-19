import Foundation
import SwiftSoup

struct ArticleDetail: Codable {
    let title: String
    let url: String
    var description: String?
    var image: String?
}

class HackerNewsApi: ObservableObject {
    // This function fetches the IDs of the articles
    func getNewsIds(type: String, completion: @escaping ([Int]) -> Void) {
        guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/\(type)stories.json") else {
            alertError("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                alertError(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                alertError("No data received")
                return
            }
            
            do {
                let ids = try JSONDecoder().decode([Int].self, from: data)
                completion(ids)
            } catch {
                alertError("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    // This function fetches details for each article based on ID
    func getArticleDetails(for ids: [Int], completion: @escaping ([ArticleDetail]) -> Void) {
        let group = DispatchGroup()
        var articles: [ArticleDetail] = []
        
        for id in ids.prefix(10) { // Limit to first 10 IDs for concurrency
            group.enter()
            guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json") else {
                print("Invalid URL for ID \(id)")
                group.leave()
                continue
            }
            
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching article \(id): \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received for article \(id)")
                    return
                }
                
                do {
                    var articleDetail = try JSONDecoder().decode(ArticleDetail.self, from: data)
                    
                    // Fetch the webpage to parse og tags
                    if let articleURL = URL(string: articleDetail.url) {
                        group.enter()
                        URLSession.shared.dataTask(with: articleURL) { data, response, error in
                            defer { group.leave() }
                            
                            if let data = data, let html = String(data: data, encoding: .utf8) {
                                do {
                                    let doc: Document = try SwiftSoup.parse(html)
                                    let description: String? = try doc.select("meta[property=og:description]").first()?.attr("content")
                                    var image: String? = try doc.select("meta[property=og:image]").first()?.attr("content")
                                    if (image != nil && !image!.starts(with: "http")) {
                                        image = articleURL.absoluteString + image!;
                                    }
                                    
                                    articleDetail.description = description
                                    articleDetail.image = image
                                } catch Exception.Error(_, let message) {
                                    print("Error parsing HTML: \(message)")
                                } catch {
                                    print("Unexpected error")
                                }
                            }
                            articles.append(articleDetail)
                        }.resume()
                    } else {
                        articles.append(articleDetail)
                    }
                } catch {
                    print("Error parsing JSON for article \(id): \(error.localizedDescription)")
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            completion(articles)
        }
        
    }
}
