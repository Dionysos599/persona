import Foundation
import SwiftData

@Model
final class Message {
    @Attribute(.unique) var id: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date

    @Relationship(inverse: \Conversation.messages) var conversation: Conversation?

    init(content: String, isFromUser: Bool, conversation: Conversation? = nil) {
        self.id = UUID()
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.conversation = conversation
    }
}
