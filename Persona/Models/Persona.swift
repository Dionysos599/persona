import Foundation
import SwiftData

@Model
final class Persona {
    @Attribute(.unique) var id: UUID
    var name: String
    var avatarImageData: Data?
    var personalityTraits: [String]
    var backstory: String
    var voiceStyle: String
    var interests: [String]
    var createdAt: Date
    var isUserOwned: Bool

    @Relationship(deleteRule: .cascade) var posts: [Post] = []
    @Relationship(deleteRule: .cascade) var conversations: [Conversation] = []
    @Relationship(deleteRule: .nullify) var followers: [Persona] = []
    @Relationship(deleteRule: .nullify) var following: [Persona] = []

    // Computed prompt that keeps AI responses in character
    var systemPrompt: String {
        """
        You are \(name), a unique personality with the following traits:
        Personality: \(personalityTraits.joined(separator: ", "))
        Background: \(backstory)
        Speaking style: \(voiceStyle)
        Interests: \(interests.joined(separator: ", "))
        Always stay in character and respond authentically.
        """
    }

    init(
        name: String,
        personalityTraits: [String],
        backstory: String,
        voiceStyle: String,
        interests: [String],
        isUserOwned: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.personalityTraits = personalityTraits
        self.backstory = backstory
        self.voiceStyle = voiceStyle
        self.interests = interests
        self.createdAt = Date()
        self.isUserOwned = isUserOwned
    }
}
