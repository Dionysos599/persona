import Foundation
import SwiftData

@Model
final class Conversation {
    @Attribute(.unique) var id: UUID
    var lastMessageAt: Date
    var isPrivateChat: Bool

    @Relationship(inverse: \Persona.conversations) var persona: Persona?
    @Relationship(deleteRule: .cascade) var messages: [Message] = []

    init(persona: Persona? = nil, isPrivateChat: Bool = false) {
        self.id = UUID()
        self.lastMessageAt = Date()
        self.isPrivateChat = isPrivateChat
        self.persona = persona
    }
}
