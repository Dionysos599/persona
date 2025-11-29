import SwiftUI
import SwiftData

struct PersonaDetailView: View {
    let persona: Persona
    
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router
    
    @Query(sort: \Post.createdAt, order: .reverse) private var allPosts: [Post]
    @Query(sort: \Persona.createdAt, order: .reverse) private var allPersonas: [Persona]
    
    @State private var viewModel: FeedViewModel?
    @State private var isFollowing: Bool = false
    @State private var showUnfollowConfirmation: Bool = false
    
    private var anyPersona: Persona? { allPersonas.first }
    
    private var personaPosts: [Post] {
        allPosts.filter { $0.author?.id == persona.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.lg) {
                // Avatar and name
                profileHeader
                
                // Action buttons (all Personas have full management features)
                ownProfileActions
                
                // Backstory
                if !persona.backstory.isEmpty {
                    backstorySection
                }
                
                // Posts section
                postsSection
            }
        }
        .navigationTitle(persona.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("取消关注", isPresented: $showUnfollowConfirmation) {
            Button("取消", role: .cancel) {
                showUnfollowConfirmation = false
            }
            Button("确认", role: .destructive) {
                toggleFollow()
                showUnfollowConfirmation = false
            }
        } message: {
            Text("确定要取消关注 \(persona.name) 吗？")
        }
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
                    router.selectedTab = .myProfile
                    router.navigate(to: .apiSettings)
                }
            }
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = FeedViewModel(aiService: AIService.shared, modelContext: modelContext)
            }
            // Check if any Persona is following this persona
            if let firstPersona = anyPersona {
                isFollowing = firstPersona.following.contains(where: { $0.id == persona.id })
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: Constants.Spacing.md) {
            PersonaAvatarView(persona: persona, size: Constants.AvatarSize.xLarge)
            
            Text(persona.name)
                .font(.title)
                .fontWeight(.bold)
            
            // Traits
            if !persona.personalityTraits.isEmpty {
                HStack(spacing: Constants.Spacing.xs) {
                    ForEach(persona.personalityTraits.prefix(4), id: \.self) { traitString in
                        if let trait = PersonalityTrait.allCases.first(where: { $0.rawValue == traitString }) {
                            Text(trait.displayName)
                                .font(.caption)
                                .padding(.horizontal, Constants.Spacing.sm)
                                .padding(.vertical, Constants.Spacing.xs)
                                .background(Color.secondaryBackground)
                                .clipShape(Capsule())
                        } else {
                            Text(traitString.capitalized)
                                .font(.caption)
                                .padding(.horizontal, Constants.Spacing.sm)
                                .padding(.vertical, Constants.Spacing.xs)
                                .background(Color.secondaryBackground)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            // Interests
            if !persona.interests.isEmpty {
                HStack(spacing: Constants.Spacing.xs) {
                    ForEach(persona.interests.prefix(3), id: \.self) { interest in
                        Text("#\(interest)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.top, Constants.Spacing.md)
    }
    
    // MARK: - Own Profile Actions
    
    private var ownProfileActions: some View {
        VStack(spacing: Constants.Spacing.md) {
            // Follow button (first)
            followButton
            
            // AI Generate Post button (second)
            Button {
                Task {
                    await generatePost()
                }
            } label: {
                HStack {
                    if viewModel?.isGeneratingPost == true {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(viewModel?.isGeneratingPost == true ? "生成中..." : "AI 生成动态")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.md)
                .background(Color.personaPrimary)
                .cornerRadius(Constants.CornerRadius.medium)
            }
            .disabled(viewModel?.isGeneratingPost == true)
            .padding(.horizontal)
            
            // Management buttons (third row)
            HStack(spacing: Constants.Spacing.md) {
                Button {
                    router.navigate(to: .privateChat(persona))
                } label: {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                        Text("私密对话")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.Spacing.md)
                    .background(Color.personaPrimary)
                    .foregroundStyle(.white)
                    .cornerRadius(Constants.CornerRadius.medium)
                }
                
                NavigationLink(value: AppRoute.editPersona(persona)) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("编辑")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.Spacing.md)
                    .background(Color.secondaryBackground)
                    .foregroundStyle(.primary)
                    .cornerRadius(Constants.CornerRadius.medium)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Follow Button
    
    private var followButton: some View {
        Button {
            if isFollowing {
                showUnfollowConfirmation = true
            } else {
                toggleFollow()
            }
        } label: {
            HStack {
                Image(systemName: isFollowing ? "person.badge.checkmark" : "person.badge.plus")
                Text(isFollowing ? "已关注" : "关注")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.Spacing.md)
            .background(isFollowing ? Color.secondaryBackground : Color.personaPrimary)
            .foregroundStyle(isFollowing ? Color.primary : Color.white)
            .cornerRadius(Constants.CornerRadius.medium)
        }
        .padding(.horizontal)
        .disabled(anyPersona == nil)
    }
    
    // MARK: - Backstory Section
    
    private var backstorySection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("关于")
                .font(.headline)
            
            Text(persona.backstory)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(Constants.CornerRadius.medium)
        .padding(.horizontal)
    }
    
    // MARK: - Posts Section
    
    private var postsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("动态")
                .font(.headline)
                .padding(.horizontal)
            
            if personaPosts.isEmpty {
                Text("还没有发布任何动态")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(personaPosts, id: \.id) { post in
                    PersonaPostCard(post: post)
                        .onTapGesture {
                            router.navigate(to: .postDetail(post))
                        }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func generatePost() async {
        await viewModel?.generatePost(for: persona)
    }
    
    private func toggleFollow() {
        // Use the first Persona for following (or could show a picker in the future)
        guard let firstPersona = anyPersona else { return }
        
        if isFollowing {
            // Unfollow
            if let index = firstPersona.following.firstIndex(where: { $0.id == persona.id }) {
                firstPersona.following.remove(at: index)
            }
            if let index = persona.followers.firstIndex(where: { $0.id == firstPersona.id }) {
                persona.followers.remove(at: index)
            }
        } else {
            // Follow
            firstPersona.following.append(persona)
            persona.followers.append(firstPersona)
        }
        
        isFollowing.toggle()
        try? modelContext.save()
    }
}

// MARK: - Persona Post Card

private struct PersonaPostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text(post.content)
                .font(.body)
                .lineLimit(nil)
            
            HStack {
                Text(post.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Label("\(post.likeCount)", systemImage: "heart")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Constants.CornerRadius.medium)
        .shadow(color: Constants.Shadow.color, radius: Constants.Shadow.radius, x: Constants.Shadow.x, y: Constants.Shadow.y)
        .padding(.horizontal)
    }
}

