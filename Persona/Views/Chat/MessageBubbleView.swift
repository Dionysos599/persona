import SwiftUI
import SwiftData

struct MessageBubbleView: View {
    let content: String
    let isFromUser: Bool
    var isStreaming: Bool = false
    
    init(message: Message) {
        self.content = message.content
        self.isFromUser = message.isFromUser
        self.isStreaming = false
    }
    
    init(content: String, isFromUser: Bool, isStreaming: Bool = false) {
        self.content = content
        self.isFromUser = isFromUser
        self.isStreaming = isStreaming
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: Constants.Spacing.sm) {
            if isFromUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromUser ? .trailing : .leading, spacing: 4) {
                if isFromUser {
                    Text(content)
                        .padding(.horizontal, Constants.Spacing.md)
                        .padding(.vertical, Constants.Spacing.sm)
                        .background(Color.personaPrimary)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.medium))
                } else {
                    MarkdownText(content: content, isStreaming: isStreaming)
                        .padding(.horizontal, Constants.Spacing.md)
                        .padding(.vertical, Constants.Spacing.sm)
                        .background(Color.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.medium))
                }
                
                if isStreaming {
                    TypingIndicator()
                        .padding(.leading, Constants.Spacing.sm)
                }
            }
            
            if !isFromUser {
                Spacer(minLength: 60)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageBubbleView(content: "Hello! How are you?", isFromUser: true)
        MessageBubbleView(content: "I'm doing great, thanks for asking!", isFromUser: false)
        MessageBubbleView(content: "This is a streaming message...", isFromUser: false, isStreaming: true)
    }
    .padding()
}

