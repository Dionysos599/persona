import SwiftUI
import SwiftData

@Observable
final class FeedViewModel {
    var isLoading: Bool = false
    var isGeneratingPost: Bool = false
    var errorMessage: String?
    var isAPIKeyError: Bool = false
    
    private let aiService: AIService
    private let modelContext: ModelContext
    
    init(aiService: AIService, modelContext: ModelContext) {
        self.aiService = aiService
        self.modelContext = modelContext
    }
    
    @MainActor
    func generatePost(for persona: Persona) async {
        isGeneratingPost = true
        errorMessage = nil
        
        do {
            let content = try await aiService.generatePost(for: persona)
            let post = Post(content: content, author: persona)
            modelContext.insert(post)
            persona.posts.append(post)
            try? modelContext.save()
        } catch {
            if let aiError = error as? AIError, aiError == .noAPIKey {
                isAPIKeyError = true
                errorMessage = "请先设置 API Key 才能使用 AI 功能"
            } else {
                isAPIKeyError = false
                errorMessage = error.localizedDescription
            }
        }
        
        isGeneratingPost = false
    }
    
    func likePost(_ post: Post, by persona: Persona) {
        if !post.likedByPersonas.contains(where: { $0.id == persona.id }) {
            post.likedByPersonas.append(persona)
            post.likeCount += 1
            try? modelContext.save()
        }
    }
    
    func unlikePost(_ post: Post, by persona: Persona) {
        if let index = post.likedByPersonas.firstIndex(where: { $0.id == persona.id }) {
            post.likedByPersonas.remove(at: index)
            post.likeCount = max(0, post.likeCount - 1)
            try? modelContext.save()
        }
    }
    
    func isLiked(_ post: Post, by persona: Persona?) -> Bool {
        guard let persona = persona else { return false }
        return post.likedByPersonas.contains(where: { $0.id == persona.id })
    }
}

