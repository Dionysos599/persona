import SwiftUI
import SwiftData

struct PostDetailView: View {
    let post: Post
    
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router
    @Query(sort: \Persona.createdAt, order: .reverse) private var allPersonas: [Persona]
    
    @State private var isLiked: Bool = false
    @State private var animateLike: Bool = false
    
    private var anyPersona: Persona? { allPersonas.first }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
                // Author section
                HStack {
                    PersonaAvatarView(persona: post.author, size: Constants.AvatarSize.large)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.author?.name ?? "Unknown")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        if let author = post.author, !author.personalityTraits.isEmpty {
                            HStack(spacing: Constants.Spacing.xs) {
                                ForEach(author.personalityTraits.prefix(2), id: \.self) { trait in
                                    Text(trait.capitalized)
                                        .font(.caption)
                                        .padding(.horizontal, Constants.Spacing.sm)
                                        .padding(.vertical, 2)
                                        .background(Color.secondaryBackground)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let author = post.author {
                        router.navigate(to: .personaProfile(author))
                    }
                }
                
                Divider()
                
                // Content
                Text(post.content)
                    .font(.body)
                    .lineSpacing(6)
                
                // Image if present
                if let imageData = post.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.medium))
                }
                
                // Metadata
                HStack {
                    Text(post.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Divider()
                
                // Actions
                HStack(spacing: Constants.Spacing.xl) {
                    Button {
                        withAnimation(Constants.Animation.spring) {
                            isLiked.toggle()
                            animateLike = true
                        }
                        handleLike()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            animateLike = false
                        }
                    } label: {
                        HStack(spacing: Constants.Spacing.sm) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.title3)
                                .scaleEffect(animateLike ? 1.3 : 1.0)
                            Text("\(post.likeCount) 喜欢")
                        }
                        .foregroundStyle(isLiked ? Color.liked : .secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.vertical, Constants.Spacing.sm)
            }
            .padding()
        }
        .navigationTitle("动态详情")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Check if any Persona has liked this post
            isLiked = allPersonas.contains { persona in
                post.likedByPersonas.contains(where: { $0.id == persona.id })
            }
        }
    }
    
    private func handleLike() {
        // Use the first Persona for liking (or could show a picker in the future)
        guard let persona = anyPersona else { return }
        
        if post.likedByPersonas.contains(where: { $0.id == persona.id }) {
            if let index = post.likedByPersonas.firstIndex(where: { $0.id == persona.id }) {
                post.likedByPersonas.remove(at: index)
                post.likeCount = max(0, post.likeCount - 1)
            }
        } else {
            post.likedByPersonas.append(persona)
            post.likeCount += 1
        }
        try? modelContext.save()
    }
}

