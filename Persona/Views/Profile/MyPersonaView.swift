import SwiftUI
import SwiftData

struct MyPersonaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Persona> { $0.isUserOwned }) private var myPersonas: [Persona]
    @State private var showCreateSheet = false
    
    var body: some View {
        Group {
            if let myPersona = myPersonas.first {
                // User has a Persona - show details
                MyPersonaDetailView(persona: myPersona)
            } else {
                // No Persona yet - show empty state with create button
                emptyStateView
            }
        }
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if myPersonas.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            PersonaCreationView(aiService: AIService.shared)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("创建你的 Persona")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Persona 是你的 AI 化身，可以代表你发布动态、与其他 Persona 互动")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.xl)
            
            Button {
                showCreateSheet = true
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("开始创建")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, Constants.Spacing.xl)
                .padding(.vertical, Constants.Spacing.md)
                .background(Color.personaGradient)
                .clipShape(Capsule())
            }
            .padding(.top, Constants.Spacing.md)
        }
        .padding()
    }
}

// MARK: - My Persona Detail View

private struct MyPersonaDetailView: View {
    let persona: Persona
    @Environment(Router.self) private var router
    @Query(sort: \Post.createdAt, order: .reverse) private var allPosts: [Post]
    
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
                            MyPostCard(post: post)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - My Post Card

private struct MyPostCard: View {
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

#Preview {
    NavigationStack {
        MyPersonaView()
    }
    .modelContainer(for: [Persona.self, Post.self, Conversation.self, Message.self])
}

