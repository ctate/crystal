import SwiftUI

struct DalleImageCard: View {
    var images: [GeneratedImage]
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            AsyncImage(url: images.first!.url) { imagePhase in
                if let image = imagePhase.image {
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                } else if imagePhase.error != nil {
                    Text("Error loading image")
                        .foregroundColor(.red)
                } else {
                    Rectangle()
                        .fill(.gray)
                        .frame(width: 300, height: 300)
                        .opacity(isAnimating ? 1.0 : 0.5)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                        .cornerRadius(10)
                        .onAppear {
                            isAnimating = true
                        }
                }
            }
            .frame(width: 300, height: 300)
        }
    }
}

struct DalleImageCardSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(.gray)
                .frame(width: 300, height: 300)
                .opacity(isAnimating ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                .cornerRadius(10)
                .onAppear {
                    isAnimating = true
                }
        }
    }
}

#Preview {
    DalleImageCard(
        images: [
            GeneratedImage(
                url: URL(
                    string: "https://files.oaiusercontent.com/file-LujgGejjz2J6g2jWT9EPEWMs?se=2024-05-10T14%3A17%3A38Z&sp=r&sv=2023-11-03&sr=b&rscc=max-age%3D31536000%2C%20immutable&rscd=attachment%3B%20filename%3De61d6cdf-3235-4c69-b072-15cecc8c1e88.webp&sig=/FKvmbT7ozVad%2BYyGQRJTOK5%2BJ4jJFb8z81UagWi0a0%3D"
                )!
            )
        ]
        
    )
}
