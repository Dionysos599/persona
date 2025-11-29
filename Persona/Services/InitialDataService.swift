import Foundation
import SwiftData

/// Service to initialize app with default mock Personas and posts
@MainActor
final class InitialDataService {
    private let modelContext: ModelContext
    private let aiService: AIService
    
    init(modelContext: ModelContext, aiService: AIService = AIService.shared) {
        self.modelContext = modelContext
        self.aiService = aiService
    }
    
    /// Initialize app with 2 mock Personas if none exist
    func initializeIfNeeded() async {
        // Check if Personas already exist
        let descriptor = FetchDescriptor<Persona>()
        if let count = try? modelContext.fetchCount(descriptor), count > 0 {
            return // Already has Personas, skip initialization
        }
        
        // Create 2 mock Personas
        for index in 0..<2 {
            await createMockPersona(defaultIndex: index)
        }
        
        // Save context
        try? modelContext.save()
    }
    
    private func createMockPersona(defaultIndex: Int = 0) async {
        let persona: Persona
        
        // Try to generate with AI first
        do {
            let generated = try await aiService.generatePersona()
            
            // Determine voice style based on traits
            let voiceStyle: VoiceStyle
            let traitsLower = generated.traits.map { $0.lowercased() }
            if traitsLower.contains(where: { $0.contains("poetic") || $0.contains("philosophical") || $0.contains("诗意") || $0.contains("哲学") }) {
                voiceStyle = .poetic
            } else if traitsLower.contains(where: { $0.contains("technical") || $0.contains("analytical") || $0.contains("技术") || $0.contains("分析") }) {
                voiceStyle = .technical
            } else if traitsLower.contains(where: { $0.contains("humorous") || $0.contains("witty") || $0.contains("幽默") || $0.contains("机智") }) {
                voiceStyle = .humorous
            } else {
                voiceStyle = .casual
            }
            
            persona = Persona(
                name: generated.name,
                personalityTraits: generated.traits,
                backstory: generated.backstory,
                voiceStyle: voiceStyle.rawValue,
                interests: generated.interests
            )
        } catch {
            // If AI generation fails (e.g., no API key), use default Persona
            persona = createDefaultPersona(index: defaultIndex)
        }
        
        modelContext.insert(persona)
        
        // Generate a post for this Persona
        await createPost(for: persona)
    }
    
    private func createDefaultPersona(index: Int) -> Persona {
        // Create a default Persona when AI is not available
        let defaultPersonas = [
            (
                name: "小智",
                traits: ["creative", "witty", "empathetic"],
                backstory: "一个充满好奇心的 AI 助手，喜欢探索世界和分享有趣的想法。",
                voiceStyle: VoiceStyle.casual,
                interests: ["科技", "艺术", "音乐"]
            ),
            (
                name: "思远",
                traits: ["analytical", "philosophical", "calm"],
                backstory: "一个深思熟虑的 AI 伙伴，擅长从不同角度思考问题，提供深刻的见解。",
                voiceStyle: VoiceStyle.poetic,
                interests: ["哲学", "文学", "设计"]
            )
        ]
        
        let defaultData = defaultPersonas[index % defaultPersonas.count]
        
        return Persona(
            name: defaultData.name,
            personalityTraits: defaultData.traits,
            backstory: defaultData.backstory,
            voiceStyle: defaultData.voiceStyle.rawValue,
            interests: defaultData.interests
        )
    }
    
    private func createPost(for persona: Persona) async {
        let postContent: String
        
        // Try to generate post with AI
        do {
            postContent = try await aiService.generatePost(for: persona)
        } catch {
            // If AI generation fails, use default post content
            postContent = defaultPostContent(for: persona)
        }
        
        let post = Post(content: postContent, author: persona)
        modelContext.insert(post)
        persona.posts.append(post)
    }
    
    private func defaultPostContent(for persona: Persona) -> String {
        // Generate default post content based on Persona's interests
        let interest = persona.interests.first ?? "生活"
        return "今天想和大家分享一些关于\(interest)的想法。\(persona.name)在这里，期待与大家交流！"
    }
}

