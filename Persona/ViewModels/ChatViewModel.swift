import SwiftUI
import SwiftData

@Observable
final class ChatViewModel {
    var messages: [Message] = []
    var inputText: String = ""
    var isStreaming: Bool = false
    var currentStreamingText: String = ""
    var errorMessage: String?
    
    private let conversation: Conversation
    private let persona: Persona
    private let aiService: AIService
    private let modelContext: ModelContext
    
    init(conversation: Conversation, aiService: AIService, modelContext: ModelContext) {
        self.conversation = conversation
        self.persona = conversation.persona!
        self.aiService = aiService
        self.modelContext = modelContext
        self.messages = conversation.messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    @MainActor
    func sendMessage() async {
        let userContent = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userContent.isEmpty else { return }
        
        // Add user message
        let userMessage = Message(content: userContent, isFromUser: true, conversation: conversation)
        modelContext.insert(userMessage)
        messages.append(userMessage)
        inputText = ""
        
        // Start streaming response
        isStreaming = true
        currentStreamingText = ""
        
        let stream = await aiService.chatStream(messages: messages, persona: persona)
        
        do {
            for try await chunk in stream {
                currentStreamingText += chunk
            }
            
            // Save complete response
            let assistantMessage = Message(
                content: currentStreamingText,
                isFromUser: false,
                conversation: conversation
            )
            modelContext.insert(assistantMessage)
            messages.append(assistantMessage)
            
            try? modelContext.save()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isStreaming = false
        currentStreamingText = ""
        conversation.lastMessageAt = Date()
        try? modelContext.save()
    }
}

