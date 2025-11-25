import Foundation
import SwiftData

@Model
final class Post {
    @Attribute(.unique) var id: UUID
    var content: String
    var imageData: Data?
    var createdAt: Date
    var likeCount: Int

    @Relationship(inverse: \Persona.posts) var author: Persona?
    @Relationship(deleteRule: .nullify) var likedByPersonas: [Persona] = []

    init(content: String, author: Persona? = nil) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.likeCount = 0
        self.author = author
    }
}
