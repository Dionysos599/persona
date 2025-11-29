import Foundation
import SwiftData

final class PersonaRecommendationService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func recommendPersonas(
        for currentPersona: Persona,
        exclude: [Persona] = [],
        limit: Int = 10
    ) -> [Persona] {
        let allPersonas = fetchAllPersonas()
        
        let candidatePersonas = allPersonas.filter { persona in
            persona.id != currentPersona.id &&
            !exclude.contains(where: { $0.id == persona.id }) &&
            !currentPersona.following.contains(where: { $0.id == persona.id })
        }
        
        guard !candidatePersonas.isEmpty else {
            return fallbackRecommendations(exclude: exclude + [currentPersona], limit: limit)
        }
        
        let scoredPersonas = candidatePersonas.map { persona in
            let score = calculateRecommendationScore(
                currentPersona: currentPersona,
                candidatePersona: persona,
                allPersonas: allPersonas
            )
            return (persona: persona, score: score)
        }
        
        return scoredPersonas
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0.persona }
    }
    
    private func calculateRecommendationScore(
        currentPersona: Persona,
        candidatePersona: Persona,
        allPersonas: [Persona]
    ) -> Double {
        let interestScore = calculateInterestSimilarity(
            currentPersona.interests,
            candidatePersona.interests
        )
        
        let personalityScore = calculatePersonalitySimilarity(
            currentPersona.personalityTraits,
            candidatePersona.personalityTraits
        )
        
        let socialScore = calculateSocialScore(
            candidatePersona: candidatePersona,
            currentPersona: currentPersona,
            allPersonas: allPersonas
        )
        
        let interactionScore = calculateInteractionScore(
            candidatePersona: candidatePersona,
            currentPersona: currentPersona
        )
        
        let diversityScore = calculateDiversityScore(
            candidatePersona: candidatePersona,
            currentPersona: currentPersona
        )
        
        return interestScore * 0.30 +
               personalityScore * 0.25 +
               socialScore * 0.20 +
               interactionScore * 0.15 +
               diversityScore * 0.10
    }
    
    private func calculateInterestSimilarity(
        _ interests1: [String],
        _ interests2: [String]
    ) -> Double {
        guard !interests1.isEmpty && !interests2.isEmpty else {
            return 0.0
        }
        
        let set1 = Set(interests1.map { $0.lowercased() })
        let set2 = Set(interests2.map { $0.lowercased() })
        
        let intersection = set1.intersection(set2)
        let union = set1.union(set2)
        
        guard !union.isEmpty else { return 0.0 }
        
        return Double(intersection.count) / Double(union.count)
    }
    
    private func calculatePersonalitySimilarity(
        _ traits1: [String],
        _ traits2: [String]
    ) -> Double {
        guard !traits1.isEmpty && !traits2.isEmpty else {
            return 0.0
        }
        
        let set1 = Set(traits1.map { $0.lowercased() })
        let set2 = Set(traits2.map { $0.lowercased() })
        
        let intersection = set1.intersection(set2)
        let union = set1.union(set2)
        
        guard !union.isEmpty else { return 0.0 }
        
        return Double(intersection.count) / Double(union.count)
    }
    
    private func calculateSocialScore(
        candidatePersona: Persona,
        currentPersona: Persona,
        allPersonas: [Persona]
    ) -> Double {
        var score = 0.0
        
        for followedPersona in currentPersona.following {
            if followedPersona.following.contains(where: { $0.id == candidatePersona.id }) {
                score += 0.5
            }
            
            if candidatePersona.following.contains(where: { $0.id == followedPersona.id }) {
                score += 0.3
            }
        }
        
        let commonFollowers = Set(currentPersona.followers.map { $0.id })
            .intersection(Set(candidatePersona.followers.map { $0.id }))
        score += Double(commonFollowers.count) * 0.1
        
        return min(score, 1.0)
    }
    
    private func calculateInteractionScore(
        candidatePersona: Persona,
        currentPersona: Persona
    ) -> Double {
        let allPosts = fetchAllPosts()
        
        let likedPosts = allPosts.filter { post in
            post.likedByPersonas.contains(where: { $0.id == currentPersona.id })
        }
        
        let candidatePosts = allPosts.filter { post in
            post.author?.id == candidatePersona.id
        }
        
        guard !likedPosts.isEmpty else { return 0.0 }
        
        let likedAuthors = Set(likedPosts.compactMap { $0.author?.id })
        if likedAuthors.contains(candidatePersona.id) {
            let candidateLikedPosts = likedPosts.filter { $0.author?.id == candidatePersona.id }
            let totalLikes = likedPosts.count
            return min(Double(candidateLikedPosts.count) / Double(totalLikes) * 2.0, 1.0)
        }
        
        let similarAuthors = likedAuthors.filter { authorId in
            allPosts.contains { post in
                post.author?.id == authorId && 
                post.likedByPersonas.contains(where: { $0.id == candidatePersona.id })
            }
        }
        
        return min(Double(similarAuthors.count) * 0.2, 1.0)
    }
    
    private func calculateDiversityScore(
        candidatePersona: Persona,
        currentPersona: Persona
    ) -> Double {
        let interestDiff = 1.0 - calculateInterestSimilarity(
            currentPersona.interests,
            candidatePersona.interests
        )
        
        let traitDiff = 1.0 - calculatePersonalitySimilarity(
            currentPersona.personalityTraits,
            candidatePersona.personalityTraits
        )
        
        return (interestDiff + traitDiff) / 2.0
    }
    
    private func fallbackRecommendations(
        exclude: [Persona],
        limit: Int
    ) -> [Persona] {
        let allPersonas = fetchAllPersonas()
        let excludeIds = Set(exclude.map { $0.id })
        
        let candidates = allPersonas.filter { !excludeIds.contains($0.id) }
        
        let scored = candidates.map { persona in
            let popularityScore = Double(persona.followers.count) * 0.4 +
                                 Double(persona.posts.count) * 0.3 +
                                 Double(persona.posts.reduce(0) { $0 + $1.likeCount }) * 0.3
            return (persona: persona, score: popularityScore)
        }
        
        return scored
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0.persona }
    }
    
    private func fetchAllPersonas() -> [Persona] {
        let descriptor = FetchDescriptor<Persona>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func fetchAllPosts() -> [Post] {
        let descriptor = FetchDescriptor<Post>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}

