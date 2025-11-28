import SwiftUI
import SwiftData

struct PrivateChatView: View {
    let persona: Persona
    
    @Environment(\.modelContext) private var modelContext
    @State private var conversation: Conversation?
    
    var body: some View {
        Group {
            if let conversation = conversation {
                ChatView(conversation: conversation)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("与 \(persona.name) 私聊")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: AppRoute.editPersona(persona)) {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .onAppear {
            loadOrCreatePrivateConversation()
        }
    }
    
    private func loadOrCreatePrivateConversation() {
        // Find existing private conversation or create new one
        let conversations = persona.conversations
        if let existing = conversations.first(where: { $0.isPrivateChat }) {
            conversation = existing
        } else {
            let newConversation = Conversation(persona: persona, isPrivateChat: true)
            modelContext.insert(newConversation)
            persona.conversations.append(newConversation)
            do {
                try modelContext.save()
                conversation = newConversation
            } catch {
                print("Failed to create conversation: \(error)")
            }
        }
    }
}

