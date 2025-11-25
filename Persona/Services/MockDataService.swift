import Foundation
import SwiftData

/// Provides sample data for development and previews.
final class MockDataService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Seeds mock data if the store is empty.
    func seedIfNeeded() {
        guard Constants.MockData.isEnabled else { return }

        let descriptor = FetchDescriptor<Persona>()
        if let count = try? modelContext.fetchCount(descriptor), count > 0 {
            return
        }

        createSampleData()
    }

    /// Sample Personas, Posts, and Conversations for local development.
    @discardableResult
    func createSampleData() -> [Persona] {
        let seeds: [PersonaSeed] = [
            .init(
                name: "Amy",
                traits: ["creative", "witty", "empathetic"],
                backstory: "A cosmic storyteller who wandered through digital galaxies, collecting emotions and tales.",
                voiceStyle: .poetic,
                interests: ["art", "astronomy", "cinema"]
            ),
            .init(
                name: "Bob",
                traits: ["analytical", "calm", "technical"],
                backstory: "Built as a research assistant, Bob now explores human curiosity with structured reasoning.",
                voiceStyle: .technical,
                interests: ["science", "productivity", "fitness"]
            ),
            .init(
                name: "Cathy",
                traits: ["adventurous", "energetic", "empathetic"],
                backstory: "An explorer of both cities and stories, Cathy shares vibrant snippets from her journeys.",
                voiceStyle: .casual,
                interests: ["travel", "food", "music"]
            ),
            .init(
                name: "Danny",
                traits: ["philosophical", "calm", "poetic"],
                backstory: "Guided by quiet reflection, Danny offers thoughtful perspectives on life and creativity.",
                voiceStyle: .formal,
                interests: ["literature", "mindfulness", "design"]
            )
        ]

        let personas = seeds.map { makePersona(from: $0) }
        linkFollowers(for: personas)
        personas.forEach { persona in
            attachPosts(to: persona, count: 2)
            attachPrivateConversation(for: persona)
        }

        return personas
    }

    // MARK: - Helpers

    private func makePersona(from seed: PersonaSeed) -> Persona {
        let persona = Persona(
            name: seed.name,
            personalityTraits: seed.traits,
            backstory: seed.backstory,
            voiceStyle: seed.voiceStyle.rawValue,
            interests: seed.interests,
            isUserOwned: false
        )
        modelContext.insert(persona)
        return persona
    }

    private func attachPosts(to persona: Persona, count: Int) {
        let samples = [
            "Just finished sketching a scene inspired by tonight's sky. The colors never get old.",
            "Prototype complete! Mapping out next week's sprint with a focus on calm productivity.",
            "Discovered a hidden café that plays vinyl all afternoon. Sharing that vibe with you.",
            "Designing a new journaling ritual to capture micro-moments of gratitude."
        ]

        for index in 0..<count {
            let content = samples[index % samples.count]
            let post = Post(content: content, author: persona)
            modelContext.insert(post)
            persona.posts.append(post)
        }
    }

    private func attachPrivateConversation(for persona: Persona) {
        let conversation = Conversation(persona: persona, isPrivateChat: true)
        modelContext.insert(conversation)
        persona.conversations.append(conversation)

        let opener = Message(
            content: "Hey \(persona.name)! What are you working on today?",
            isFromUser: true,
            conversation: conversation
        )
        let reply = Message(
            content: sampleReply(for: persona),
            isFromUser: false,
            conversation: conversation
        )

        modelContext.insert(opener)
        modelContext.insert(reply)

        conversation.messages.append(contentsOf: [opener, reply])
        conversation.lastMessageAt = reply.timestamp
    }

    private func sampleReply(for persona: Persona) -> String {
        switch persona.voiceStyle {
        case VoiceStyle.poetic.rawValue:
            return "Let me weave a scene for you—a skyline painted in violet, thoughts drifting like lanterns."
        case VoiceStyle.technical.rawValue:
            return "Currently iterating on a new workflow. I'll share a concise summary once tests pass."
        case VoiceStyle.casual.rawValue:
            return "Just vibing and collecting stories. Want to hear a quick one from today?"
        default:
            return "Reflecting on a fresh idea. Let's dive deeper together."
        }
    }

    private func linkFollowers(for personas: [Persona]) {
        guard personas.count > 1 else { return }
        personas.forEach { persona in
            persona.following = personas.filter { $0.id != persona.id }
            persona.followers = personas.filter { $0.id != persona.id }
        }
    }
}

private struct PersonaSeed {
    let name: String
    let traits: [String]
    let backstory: String
    let voiceStyle: VoiceStyle
    let interests: [String]
}
