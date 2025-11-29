import SwiftUI
import SwiftData

struct MyPersonaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Persona.createdAt, order: .reverse) private var allPersonas: [Persona]
    @State private var showCreateSheet = false
    
    var body: some View {
        Group {
            if allPersonas.isEmpty {
                emptyStateView
            } else {
                personaListView
            }
        }
        .navigationTitle("Persona")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
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
                    Image(systemName: "person.crop.circle.badge.plus")
                    Text("开始创建")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.md)
                .background(Color.secondaryBackground)
                .cornerRadius(Constants.CornerRadius.large)
            }
            .buttonStyle(.plain)
            .padding(.top, Constants.Spacing.md)
            .padding(.horizontal, Constants.Spacing.md)
        }
        .padding()
    }
    
    private var personaListView: some View {
        List {
            ForEach(allPersonas) { persona in
                NavigationLink(value: AppRoute.myPersonaDetail(persona)) {
                    PersonaListRow(persona: persona)
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Persona List Row

private struct PersonaListRow: View {
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
        MyPersonaView()
    }
    .modelContainer(for: [Persona.self, Post.self, Conversation.self, Message.self])
}

