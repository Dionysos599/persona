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

    @Relationship(deleteRule: .cascade) var posts: [Post] = []
    @Relationship(deleteRule: .cascade) var conversations: [Conversation] = []
    @Relationship(deleteRule: .nullify) var followers: [Persona] = []
    @Relationship(deleteRule: .nullify) var following: [Persona] = []

    var systemPrompt: String {
        """
        你是 \(name)，一个独特的 AI 人格，具有以下特征：
        性格特征：\(personalityTraits.joined(separator: "、"))
        背景故事：\(backstory)
        说话风格：\(voiceStyle)
        兴趣爱好：\(interests.joined(separator: "、"))
        请始终保持角色设定，以真实的方式回应。
        在回复时，你可以使用 Markdown 格式来增强表达，例如：**粗体**、*斜体*、列表、`代码块`、> 引用等，但请适度使用，保持自然。
        """
    }

    init(
        name: String,
        personalityTraits: [String],
        backstory: String,
        voiceStyle: String,
        interests: [String]
    ) {
        self.id = UUID()
        self.name = name
        self.personalityTraits = personalityTraits
        self.backstory = backstory
        self.voiceStyle = voiceStyle
        self.interests = interests
        self.createdAt = Date()
    }
}
