import SwiftUI
import SwiftData

struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router
    
    @Query(sort: \Post.createdAt, order: .reverse) private var posts: [Post]
    @Query(sort: \Persona.createdAt, order: .reverse) private var allPersonas: [Persona]
    
    @State private var viewModel: FeedViewModel?
    @State private var discoveryViewModel: PersonaDiscoveryViewModel?
    
    private var anyPersona: Persona? { allPersonas.first }
    
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
            try? await Task.sleep(nanoseconds: 500_000_000)
            if let discoveryViewModel = discoveryViewModel {
                await discoveryViewModel.refreshRecommendations(for: anyPersona)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = FeedViewModel(aiService: AIService.shared, modelContext: modelContext)
            }
            if discoveryViewModel == nil {
                discoveryViewModel = PersonaDiscoveryViewModel(modelContext: modelContext)
                Task {
                    await discoveryViewModel?.loadRecommendations(for: anyPersona)
                }
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
                if let discoveryViewModel = discoveryViewModel {
                    PersonaDiscoverySection(
                        recommendedPersonas: discoveryViewModel.recommendedPersonas,
                        currentPersona: anyPersona,
                        onPersonaTap: { persona in
                            router.navigate(to: .personaProfile(persona))
                        },
                        onFollow: { persona in
                            handleFollow(persona)
                        }
                    )
                }
                
                ForEach(posts) { post in
                    PostCardView(
                        post: post,
                        allPersonas: allPersonas,
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
        guard let persona = anyPersona else {
            return
        }
        
        if viewModel?.isLiked(post, by: persona) == true {
            viewModel?.unlikePost(post, by: persona)
        } else {
            viewModel?.likePost(post, by: persona)
        }
    }
    
    private func handleFollow(_ persona: Persona) {
        guard let currentPersona = anyPersona else {
            return
        }
        
        if currentPersona.following.contains(where: { $0.id == persona.id }) {
            if let index = currentPersona.following.firstIndex(where: { $0.id == persona.id }) {
                currentPersona.following.remove(at: index)
            }
            if let index = persona.followers.firstIndex(where: { $0.id == currentPersona.id }) {
                persona.followers.remove(at: index)
            }
        } else {
            currentPersona.following.append(persona)
            persona.followers.append(currentPersona)
        }
        
        try? modelContext.save()
        
        Task {
            await discoveryViewModel?.refreshRecommendations(for: currentPersona)
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

