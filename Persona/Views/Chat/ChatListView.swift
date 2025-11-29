import SwiftUI
import SwiftData

struct ChatListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router
    
    @Query(sort: \Conversation.lastMessageAt, order: .reverse) private var conversations: [Conversation]
    
    var body: some View {
        Group {
            if conversations.isEmpty {
                emptyStateView
            } else {
                conversationListView
            }
        }
        .navigationTitle("对话")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("还没有对话")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("去关注一些 Persona 并开始对话吧！")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var conversationListView: some View {
        List {
            ForEach(conversations) { conversation in
                ConversationRow(conversation: conversation)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.navigate(to: .chat(conversation))
                    }
            }
        }
        .listStyle(.plain)
    }
}

// Conversation Row

private struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            PersonaAvatarView(persona: conversation.persona, size: Constants.AvatarSize.large, showBorder: false)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.persona?.name ?? "Unknown")
                    .font(.headline)
                
                if let lastMessage = conversation.messages.last {
                    Text(lastMessage.content)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text("开始对话...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(conversation.lastMessageAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
}

#Preview {
    NavigationStack {
        ChatListView()
    }
    .environment(Router())
    .modelContainer(for: [Persona.self, Post.self, Conversation.self, Message.self])
}

