import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

func sendImageToOpenAIVisionAPI(image: PlatformImage) {
    let imageData: Data?
    
    #if canImport(UIKit)
    imageData = image.jpegData(compressionQuality: 0.9)
    #elseif canImport(AppKit)
    guard let tiffData = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData) else {
        print("Failed to convert NSImage to Data")
        return
    }
    imageData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
    #endif
    
    guard let dataToSend = imageData else { return }
    let url = URL(string: "https://api.openai.com/v1/vision")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = dataToSend

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error: \(error?.localizedDescription ?? "No error description")")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            print(json)
        } catch {
            print("Failed to convert data to JSON")
        }
    }

    task.resume()
}
