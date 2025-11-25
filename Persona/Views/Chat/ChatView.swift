import SwiftUI
import SwiftData

struct ChatView: View {
    let conversation: Conversation
    
    var body: some View {
        VStack {
            Text("Chat")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Conversation ID: \(conversation.id.uuidString.prefix(8))")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            Text("Chat View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .navigationTitle(conversation.persona?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

