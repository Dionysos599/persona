import SwiftUI
import SwiftData

struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router
    
    @Query(sort: \Post.createdAt, order: .reverse) private var posts: [Post]
    @Query(filter: #Predicate<Persona> { $0.isUserOwned }) private var myPersonas: [Persona]
    
    @State private var viewModel: FeedViewModel?
    
    private var anyMyPersona: Persona? { myPersonas.first }
    
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
        .refreshable {
            // Refresh logic - in a real app would fetch from server
            try? await Task.sleep(nanoseconds: 500_000_000)
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
            
            Text("创建 Persona 并发布第一条动态吧！")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                router.selectedTab = .persona
            } label: {
                HStack {
                    Text("我的 Persona")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.md)
                .background(Color.secondaryBackground)
                .cornerRadius(Constants.CornerRadius.large)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Constants.Spacing.md)
        }
        .padding()
    }
    
    private var feedListView: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Spacing.md) {
                ForEach(posts) { post in
                    PostCardView(
                        post: post,
                        myPersonas: myPersonas,
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
    
    private func handleLike(_ post: Post) {
        // Use the first user Persona for liking (or could show a picker in the future)
        guard let persona = anyMyPersona else {
            // No user Persona, can't like
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

