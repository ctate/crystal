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
