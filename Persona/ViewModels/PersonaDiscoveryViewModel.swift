import SwiftUI
import SwiftData

@Observable
final class PersonaDiscoveryViewModel {
    var recommendedPersonas: [Persona] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let recommendationService: PersonaRecommendationService
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.recommendationService = PersonaRecommendationService(modelContext: modelContext)
    }
    
    @MainActor
    func loadRecommendations(for currentPersona: Persona?) async {
        guard let currentPersona = currentPersona else {
            recommendedPersonas = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        await Task { @MainActor in
            let recommendations = recommendationService.recommendPersonas(
                for: currentPersona,
                limit: 10
            )
            recommendedPersonas = recommendations
            isLoading = false
        }.value
    }
    
    @MainActor
    func refreshRecommendations(for currentPersona: Persona?) async {
        await loadRecommendations(for: currentPersona)
    }
}

