import SwiftUI
import SwiftData

struct PersonaDiscoverySection: View {
    let recommendedPersonas: [Persona]
    let currentPersona: Persona?
    let onPersonaTap: (Persona) -> Void
    let onFollow: (Persona) -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        if !recommendedPersonas.isEmpty {
            VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                HStack {
                    Text("Persona 发现")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Constants.Spacing.md) {
                        ForEach(recommendedPersonas) { persona in
                            PersonaRecommendationCard(
                                persona: persona,
                                currentPersona: currentPersona,
                                onTap: {
                                    onPersonaTap(persona)
                                },
                                onFollow: {
                                    onFollow(persona)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, Constants.Spacing.md)
        }
    }
}

private struct PersonaRecommendationCard: View {
    let persona: Persona
    let currentPersona: Persona?
    let onTap: () -> Void
    let onFollow: () -> Void
    
    @State private var isFollowing: Bool = false
    
    var body: some View {
        VStack(spacing: Constants.Spacing.sm) {
            PersonaAvatarView(persona: persona, size: Constants.AvatarSize.large)
            
            Text(persona.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            if !persona.personalityTraits.isEmpty {
                HStack(spacing: Constants.Spacing.xs) {
                    ForEach(persona.personalityTraits.prefix(2), id: \.self) { trait in
                        Text(trait)
                            .font(.caption2)
                            .padding(.horizontal, Constants.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color.secondaryBackground)
                            .clipShape(Capsule())
                    }
                }
            }
            
            if !persona.interests.isEmpty {
                HStack(spacing: Constants.Spacing.xs) {
                    ForEach(persona.interests.prefix(2), id: \.self) { interest in
                        Text("#\(interest)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Button {
                onFollow()
                isFollowing.toggle()
            } label: {
                Text(isFollowing ? "已关注" : "关注")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isFollowing ? Color.primary : Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.Spacing.xs)
                    .background(isFollowing ? Color.secondaryBackground : Color.personaPrimary)
                    .cornerRadius(Constants.CornerRadius.small)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 140)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Constants.CornerRadius.medium)
        .shadow(color: Constants.Shadow.color, radius: Constants.Shadow.radius, x: Constants.Shadow.x, y: Constants.Shadow.y)
        .onTapGesture {
            onTap()
        }
        .onAppear {
            if let currentPersona = currentPersona {
                isFollowing = currentPersona.following.contains(where: { $0.id == persona.id })
            }
        }
    }
}

