import Foundation
import SwiftData

@Model
final class Conversation: Identifiable, ObservableObject {
    let id = UUID()
    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message]
    let createdAt: Date
    
    init(messages: [Message] = []) {
        self.messages = messages
        self.createdAt = Date()
    }
}
