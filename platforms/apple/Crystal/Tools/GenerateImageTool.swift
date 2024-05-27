import Foundation
import SwiftUI

class GenerateImageTool {
    static let name = "generate_image"
    
    static let function = [
        "type": "function",
        "function": [
            "name": "generate_image",
            "description": "This function generates images based on specific user-provided text descriptions. Do NOT use this function unless the user provides an explicit request for image generation.",
            "parameters": [
                "type": "object",
                "properties": [
                    "subject": [
                        "type": "string"
                    ]
                ],
                "required": [
                    "subject"
                ]
            ]
        ]
    ] as [String : Any]
    
    static func fetch(_ newMessage: Message) async throws -> ToolResponse {
        struct Response: Codable {
            let subject: String
        }
        
        guard let result = try? JSONDecoder().decode(Response.self, from: (newMessage.arguments ?? "{}").data(using: .utf8)!) else {
            throw NSError(domain: "GenerateImageTool", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode subject"])
        }
        
        guard let images = try? await OpenAiApi().generateImage(prompt: result.subject) else {
            throw NSError(domain: "GenerateImageTool", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to generate image"])
        }
        
        let propsData = try JSONSerialization.data(withJSONObject: [
            "images": images.map { ["url": $0.url.absoluteString] }
        ])
        
        return ToolResponse(
            props: String(data: propsData, encoding: .utf8)!,
            text: "Generate Image",
            view: AnyView(DalleImageCard(
                images: images
            ))
        )
    }
    
    static func render(_ message: Message) -> AnyView {
        struct Props: Codable {
            let images: [GeneratedImage]
        }
        
        guard let result = try? JSONDecoder().decode(Props.self, from: (message.props ?? "{}").data(using: .utf8)!) else {
            return AnyView(TextCard(text: LocalizedStringKey("Failed")))
        }
        
        return AnyView(DalleImageCard(images: result.images))
    }
}
