import SwiftUI
import MarkdownUI

struct MarkdownText: View {
    let content: String
    var isStreaming: Bool = false
    
    init(content: String, isStreaming: Bool = false) {
        self.content = content
        self.isStreaming = isStreaming
    }
    
    var body: some View {
        if isStreaming {
            streamingMarkdownView
        } else {
            markdownView
        }
    }
    
    private var markdownView: some View {
        Markdown(content)
            .markdownTextStyle(\.text) {
                FontSize(.em(1))
                ForegroundColor(.primary)
            }
            .markdownTextStyle(\.code) {
                FontFamilyVariant(.monospaced)
                FontSize(.em(0.9))
                ForegroundColor(.primary)
                BackgroundColor(Color.secondary.opacity(0.2))
            }
            .markdownTextStyle(\.strong) {
                FontWeight(.semibold)
            }
            .markdownTextStyle(\.emphasis) {
                FontStyle(.italic)
            }
            .markdownBlockStyle(\.blockquote) { configuration in
                configuration.label
                    .padding(.leading, Constants.Spacing.md)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 3)
                    }
            }
    }
    
    private var streamingMarkdownView: some View {
        Group {
            if isValidMarkdown(content) {
                markdownView
            } else {
                Text(content)
                    .font(.body)
            }
        }
    }
    
    private func isValidMarkdown(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return false
        }
        
        let incompletePatterns = [
            "```[^`]*$",
            "`[^`]*$",
            "\\*\\*[^*]*$",
            "\\*[^*]*$",
            "\\[.*\\]\\([^)]*$"
        ]
        
        for pattern in incompletePatterns {
            if text.range(of: pattern, options: .regularExpression) != nil {
                return false
            }
        }
        
        return true
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Constants.Spacing.md) {
        MarkdownText(content: "这是**粗体**和*斜体*文本")
        MarkdownText(content: "使用 `代码` 和代码块：\n```swift\nlet x = 1\n```")
        MarkdownText(content: "> 这是一个引用\n> 多行引用")
        MarkdownText(content: "流式渲染中...", isStreaming: true)
    }
    .padding()
}
