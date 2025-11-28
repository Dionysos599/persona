import SwiftUI
import SwiftData

struct PostCardView: View {
    let post: Post
    let myPersona: Persona?
    let onLike: () -> Void
    let onAuthorTap: () -> Void
    
    @State private var isLiked: Bool = false
    @State private var animateLike: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            // Author info
            HStack {
                PersonaAvatarView(persona: post.author, size: Constants.AvatarSize.medium)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author?.name ?? "Unknown")
                        .font(.headline)
                    Text(post.createdAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onAuthorTap()
            }
            
            // Content
            Text(post.content)
                .font(.body)
                .lineLimit(nil)
            
            // Image if present
            if let imageData = post.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.medium))
            }
            
            // Actions
            HStack {
                Button {
                    withAnimation(Constants.Animation.spring) {
                        isLiked.toggle()
                        animateLike = true
                    }
                    onLike()
                    
                    // Reset animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        animateLike = false
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(isLiked ? Color.liked : .secondary)
                            .scaleEffect(animateLike ? 1.3 : 1.0)
                        Text("\(post.likeCount)")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.large))
        .shadow(color: Constants.Shadow.color, radius: Constants.Shadow.radius, x: Constants.Shadow.x, y: Constants.Shadow.y)
        .onAppear {
            // Check if current user has liked this post
            if let myPersona = myPersona {
                isLiked = post.likedByPersonas.contains(where: { $0.id == myPersona.id })
            }
        }
    }
}

#Preview {
    PostCardView(
        post: Post(content: "This is a sample post content that demonstrates what a post looks like in the feed."),
        myPersona: nil,
        onLike: {},
        onAuthorTap: {}
    )
    .padding()
}

