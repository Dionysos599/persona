import SwiftUI
import SwiftData

struct PersonaDetailView: View {
    let persona: Persona
    
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router
    
    @Query(sort: \Post.createdAt, order: .reverse) private var allPosts: [Post]
    @State private var viewModel: FeedViewModel?
    @State private var showGeneratePostAlert = false
    
    private var myPosts: [Post] {
        allPosts.filter { $0.author?.id == persona.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.lg) {
                // Avatar and name
                VStack(spacing: Constants.Spacing.md) {
                    if let imageData = persona.avatarImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: Constants.AvatarSize.xLarge, height: Constants.AvatarSize.xLarge)
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(Color.personaGradient, lineWidth: 3)
                            }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: Constants.AvatarSize.xLarge, height: Constants.AvatarSize.xLarge)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(persona.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Traits
                    if !persona.personalityTraits.isEmpty {
                        HStack(spacing: Constants.Spacing.xs) {
                            ForEach(persona.personalityTraits.prefix(3), id: \.self) { trait in
                                Text(trait.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, Constants.Spacing.sm)
                                    .padding(.vertical, Constants.Spacing.xs)
                                    .background(Color.secondaryBackground)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.top, Constants.Spacing.md)
                
                // Backstory
                if !persona.backstory.isEmpty {
                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        Text("背景故事")
                            .font(.headline)
                        Text(persona.backstory)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondaryBackground)
                    .cornerRadius(Constants.CornerRadius.medium)
                    .padding(.horizontal)
                }
                
                // Action buttons
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
                        .background(Color.secondaryBackground)
                        .foregroundStyle(.primary)
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
                
                // Generate Post button
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
                
                // My posts section
                VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                    Text("我的动态")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if myPosts.isEmpty {
                        Text("还没有发布任何动态")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(myPosts.prefix(5)) { post in
                            PersonaPostCard(post: post)
                                .onTapGesture {
                                    router.navigate(to: .postDetail(post))
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle(persona.name)
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
                viewModel = FeedViewModel(aiService: AIService.shared, modelContext: modelContext)
            }
        }
    }
    
    private func generatePost() async {
        await viewModel?.generatePost(for: persona)
    }
}

// MARK: - Persona Post Card

private struct PersonaPostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text(post.content)
                .font(.body)
            
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

