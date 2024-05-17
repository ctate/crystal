import SwiftUI

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
