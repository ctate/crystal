import Foundation
import SwiftData

@Model
final class Message: Identifiable, ObservableObject {
    let id = UUID()
    var text: String
    var role: String
    var provider: String?
    var model: String?
    var function: String?
    var arguments: String?
    var props: String?
    var timestamp: Date
    var tokensIn: Int?
    var tokensOut: Int?
    var tokensTotal: Int?    
    var conversation: Conversation?
    
    init(
        text: String,
        role: String,
        timestamp: Date,
        provider: String?,
        model: String?,
        function: String?,
        arguments: String?,
        props: String?,
        tokensIn: Int?,
        tokensOut: Int?,
        tokensTotal: Int?,
        conversation: Conversation? = nil
    ) {
        self.text = text
        self.role = role
        self.timestamp = timestamp
        self.provider = provider
        self.model = model
        self.function = function
        self.arguments = arguments
        self.props = props
        self.tokensIn = tokensIn
        self.tokensOut = tokensOut
        self.tokensTotal = tokensTotal
        self.conversation = conversation
    }
}
