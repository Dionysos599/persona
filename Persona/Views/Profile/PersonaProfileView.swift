import SwiftUI
import SwiftData

struct PersonaProfileView: View {
    let persona: Persona
    
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router
    @Query(filter: #Predicate<Persona> { $0.isUserOwned }) private var myPersonas: [Persona]
    @Query(sort: \Post.createdAt, order: .reverse) private var allPosts: [Post]
    
    @State private var isFollowing: Bool = false
    
    private var anyMyPersona: Persona? { myPersonas.first }
    private var isOwnProfile: Bool { persona.isUserOwned }
    
    private var personaPosts: [Post] {
        allPosts.filter { $0.author?.id == persona.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.lg) {
                // Header
                profileHeader
                
                // Stats
                statsSection
                
                // Actions
                if !isOwnProfile {
                    actionButtons
                }
                
                // Backstory
                if !persona.backstory.isEmpty {
                    backstorySection
                }
                
                // Posts
                postsSection
            }
            .padding()
        }
        .navigationTitle(persona.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Check if any of user's Personas is following this persona
            if let myPersona = anyMyPersona {
                isFollowing = myPersona.following.contains(where: { $0.id == persona.id })
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: Constants.Spacing.md) {
            PersonaAvatarView(persona: persona, size: Constants.AvatarSize.xLarge)
            
            Text(persona.name)
                .font(.title)
                .fontWeight(.bold)
            
            // Traits
            if !persona.personalityTraits.isEmpty {
                HStack(spacing: Constants.Spacing.xs) {
                    ForEach(persona.personalityTraits.prefix(4), id: \.self) { trait in
                        Text(trait.capitalized)
                            .font(.caption)
                            .padding(.horizontal, Constants.Spacing.sm)
                            .padding(.vertical, Constants.Spacing.xs)
                            .background(Color.secondaryBackground)
                            .clipShape(Capsule())
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
    }
    
    private var statsSection: some View {
        HStack(spacing: Constants.Spacing.xl) {
            statItem(value: personaPosts.count, label: "动态")
            statItem(value: persona.followers.count, label: "粉丝")
            statItem(value: persona.following.count, label: "关注")
        }
        .padding(.vertical, Constants.Spacing.md)
    }
    
    private func statItem(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: Constants.Spacing.md) {
            Button {
                toggleFollow()
            } label: {
                HStack {
                    Image(systemName: isFollowing ? "person.badge.minus" : "person.badge.plus")
                    Text(isFollowing ? "取消关注" : "关注")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.md)
                .background(isFollowing ? Color.secondaryBackground : Color.personaPrimary)
                // Use explicit Color types to avoid HierarchicalShapeStyle vs Color mismatch
                .foregroundStyle(isFollowing ? Color.primary : Color.white)
                .cornerRadius(Constants.CornerRadius.medium)
            }
            
            Button {
                startChat()
            } label: {
                HStack {
                    Image(systemName: "bubble.left")
                    Text("对话")
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
    }
    
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
    }
    
    private var postsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("动态")
                .font(.headline)
            
            if personaPosts.isEmpty {
                Text("还没有发布任何动态")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.Spacing.xl)
            } else {
                ForEach(personaPosts) { post in
                    ProfilePostCard(post: post)
                        .onTapGesture {
                            router.navigate(to: .postDetail(post))
                        }
                }
            }
        }
    }
    
    private func toggleFollow() {
        // Use the first user Persona for following (or could show a picker in the future)
        guard let myPersona = anyMyPersona else { return }
        
        if isFollowing {
            // Unfollow
            if let index = myPersona.following.firstIndex(where: { $0.id == persona.id }) {
                myPersona.following.remove(at: index)
            }
            if let index = persona.followers.firstIndex(where: { $0.id == myPersona.id }) {
                persona.followers.remove(at: index)
            }
        } else {
            // Follow
            myPersona.following.append(persona)
            persona.followers.append(myPersona)
        }
        
        isFollowing.toggle()
        try? modelContext.save()
    }
    
    private func startChat() {
        // Find or create conversation
        if let existingConversation = persona.conversations.first(where: { !$0.isPrivateChat }) {
            router.navigate(to: .chat(existingConversation))
        } else {
            let conversation = Conversation(persona: persona, isPrivateChat: false)
            modelContext.insert(conversation)
            persona.conversations.append(conversation)
            try? modelContext.save()
            router.navigate(to: .chat(conversation))
        }
    }
}

// MARK: - Profile Post Card

private struct ProfilePostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text(post.content)
                .font(.body)
                .lineLimit(3)
            
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
    }
}

