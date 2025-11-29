import SwiftUI
import SwiftData

struct ChatView: View {
    let conversation: Conversation
    
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router
    @State private var viewModel: ChatViewModel?
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: Constants.Spacing.md) {
                        ForEach(viewModel?.messages ?? []) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        // Streaming message
                        if viewModel?.isStreaming == true, let streamingText = viewModel?.currentStreamingText {
                            MessageBubbleView(
                                content: streamingText,
                                isFromUser: false,
                                isStreaming: true
                            )
                            .id("streaming")
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel?.messages.count ?? 0) {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel?.isStreaming ?? false) {
                    if viewModel?.isStreaming == true {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            
            Divider()
            
            // Input bar
            HStack(spacing: Constants.Spacing.sm) {
                TextField("输入消息...", text: Binding(
                    get: { viewModel?.inputText ?? "" },
                    set: { viewModel?.inputText = $0 }
                ), axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .focused($isInputFocused)
                .onSubmit {
                    Task {
                        await viewModel?.sendMessage()
                    }
                }
                
                Button {
                    Task {
                        await viewModel?.sendMessage()
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle((viewModel?.inputText.isEmpty == false && viewModel?.isStreaming == false) ? Color.personaPrimary : .secondary)
                }
                .disabled(viewModel?.inputText.isEmpty == true || viewModel?.isStreaming == true)
            }
            .padding()
            .background(Color.cardBackground)
        }
        .navigationTitle(conversation.persona?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .alert("错误", isPresented: Binding(
            get: { viewModel?.errorMessage != nil },
            set: { if !$0 { 
                viewModel?.errorMessage = nil
                viewModel?.isAPIKeyError = false
            } }
        )) {
            Button("确定") {
                viewModel?.errorMessage = nil
                viewModel?.isAPIKeyError = false
            }
            if viewModel?.isAPIKeyError == true {
                Button("前往添加") {
                    viewModel?.errorMessage = nil
                    viewModel?.isAPIKeyError = false
                    router.selectedTab = .settings
                    router.navigate(to: .apiSettings)
                }
            }
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ChatViewModel(
                    conversation: conversation,
                    aiService: AIService.shared,
                    modelContext: modelContext
                )
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel?.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        } else if viewModel?.isStreaming == true {
            // Scroll to show streaming message
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    proxy.scrollTo("streaming", anchor: .bottom)
                }
            }
        }
    }
}

