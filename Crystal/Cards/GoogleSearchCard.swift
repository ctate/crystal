import SwiftUI

struct GoogleSearchCardView: View {
    let result: SearchResult
    
    var body: some View {
        AdaptiveHeightView {
            VStack(alignment: .leading, spacing: 10) {
                Text(result.title)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        openLink(urlString: result.link)
                    }
                
                Text(result.snippet)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(result.link)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding()
        }
    }
}

struct GoogleSearchCard: View {
    var results: [SearchResult]
    
    var body: some View {
        List {
            ForEach(results, id: \.self) { result in
                GoogleSearchCardView(result: result)
            }
        }
    }
}
