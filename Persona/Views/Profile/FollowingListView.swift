import SwiftUI
import SwiftData

struct FollowingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Persona.createdAt, order: .reverse) private var allPersonas: [Persona]
    
    private var followingPersonas: [Persona] {
        guard let firstPersona = allPersonas.first else { return [] }
        return firstPersona.following
    }
    
    var body: some View {
        Group {
            if followingPersonas.isEmpty {
                emptyStateView
            } else {
                followingListView
            }
        }
        .navigationTitle("关注列表")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("还没有关注任何人")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("在广场中发现有趣的 Persona 并关注他们吧！")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.xl)
        }
        .padding()
    }
    
    private var followingListView: some View {
        List {
            ForEach(followingPersonas) { persona in
                NavigationLink(value: AppRoute.personaProfile(persona)) {
                    FollowingListRow(persona: persona)
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Following List Row

private struct FollowingListRow: View {
    let persona: Persona
    @Query(sort: \Post.createdAt, order: .reverse) private var allPosts: [Post]
    
    private var postCount: Int {
        allPosts.filter { $0.author?.id == persona.id }.count
    }
    
    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            PersonaAvatarView(persona: persona, size: Constants.AvatarSize.large, showBorder: false)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(persona.name)
                    .font(.headline)
                
                if !persona.personalityTraits.isEmpty {
                    HStack(spacing: Constants.Spacing.xs) {
                        ForEach(persona.personalityTraits.prefix(2), id: \.self) { traitString in
                            if let trait = PersonalityTrait.allCases.first(where: { $0.rawValue == traitString }) {
                                Text(trait.displayName)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondaryBackground)
                                    .clipShape(Capsule())
                            } else {
                                Text(traitString.capitalized)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondaryBackground)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                HStack(spacing: Constants.Spacing.sm) {
                    Label("\(postCount)", systemImage: "square.and.pencil")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
}

#Preview {
    NavigationStack {
        FollowingListView()
    }
    .modelContainer(for: [Persona.self, Post.self, Conversation.self, Message.self])
}

