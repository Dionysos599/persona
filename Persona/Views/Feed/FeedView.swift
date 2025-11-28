import SwiftUI
import SwiftData

struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router
    
    @Query(sort: \Post.createdAt, order: .reverse) private var posts: [Post]
    @Query(filter: #Predicate<Persona> { $0.isUserOwned }) private var myPersonas: [Persona]
    
    @State private var viewModel: FeedViewModel?
    @State private var showCreatePersonaAlert = false
    
    private var myPersona: Persona? { myPersonas.first }
    
    var body: some View {
        Group {
            if posts.isEmpty {
                emptyStateView
            } else {
                feedListView
            }
        }
        .navigationTitle("社交广场")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if myPersona != nil {
                    Button {
                        Task {
                            await generatePost()
                        }
                    } label: {
                        if viewModel?.isGeneratingPost == true {
                            ProgressView()
                        } else {
                            Image(systemName: "plus.bubble")
                        }
                    }
                    .disabled(viewModel?.isGeneratingPost == true)
                }
            }
        }
        .refreshable {
            // Refresh logic - in a real app would fetch from server
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
        .alert("需要创建 Persona", isPresented: $showCreatePersonaAlert) {
            Button("去创建") {
                router.selectedTab = .myPersona
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("请先在「我的」页面创建你的 Persona，才能发布动态")
        }
        .alert("错误", isPresented: Binding(
            get: { viewModel?.errorMessage != nil },
            set: { if !$0 { viewModel?.errorMessage = nil } }
        )) {
            Button("确定") {
                viewModel?.errorMessage = nil
            }
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = FeedViewModel(aiService: AIService.shared, modelContext: modelContext)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("还没有动态")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("创建你的 Persona 并发布第一条动态吧！")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if myPersona != nil {
                Button {
                    Task {
                        await generatePost()
                    }
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("AI 生成动态")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Constants.Spacing.xl)
                    .padding(.vertical, Constants.Spacing.md)
                    .background(Color.personaGradient)
                    .clipShape(Capsule())
                }
                .disabled(viewModel?.isGeneratingPost == true)
            } else {
                Button {
                    router.selectedTab = .myPersona
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("创建 Persona")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Constants.Spacing.xl)
                    .padding(.vertical, Constants.Spacing.md)
                    .background(Color.personaGradient)
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
    }
    
    private var feedListView: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Spacing.md) {
                ForEach(posts) { post in
                    PostCardView(
                        post: post,
                        myPersona: myPersona,
                        onLike: {
                            handleLike(post)
                        },
                        onAuthorTap: {
                            if let author = post.author {
                                router.navigate(to: .personaProfile(author))
                            }
                        }
                    )
                    .onTapGesture {
                        router.navigate(to: .postDetail(post))
                    }
                }
            }
            .padding()
        }
    }
    
    private func generatePost() async {
        guard let persona = myPersona else {
            showCreatePersonaAlert = true
            return
        }
        await viewModel?.generatePost(for: persona)
    }
    
    private func handleLike(_ post: Post) {
        guard let persona = myPersona else {
            showCreatePersonaAlert = true
            return
        }
        
        if viewModel?.isLiked(post, by: persona) == true {
            viewModel?.unlikePost(post, by: persona)
        } else {
            viewModel?.likePost(post, by: persona)
        }
    }
}

#Preview {
    NavigationStack {
        FeedView()
    }
    .environment(Router())
    .modelContainer(for: [Persona.self, Post.self, Conversation.self, Message.self])
}

