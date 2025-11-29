import SwiftUI
import SwiftData
import PhotosUI

@Observable
final class PersonaCreationViewModel {
    // MARK: - State
    var name: String = ""
    var selectedTraits: Set<String> = []
    var backstory: String = ""
    var voiceStyle: VoiceStyle = .casual
    var interests: [String] = []
    var avatarImage: UIImage?
    var selectedPhoto: PhotosPickerItem?
    
    var isGenerating: Bool = false
    var errorMessage: String?
    var isAPIKeyError: Bool = false
    
    // MARK: - Dependencies
    private let aiService: AIService
    private let modelContext: ModelContext
    
    init(aiService: AIService, modelContext: ModelContext) {
        self.aiService = aiService
        self.modelContext = modelContext
    }
    
    // MARK: - Computed Properties
    var isValid: Bool {
        !name.isEmpty && !selectedTraits.isEmpty && !backstory.isEmpty
    }
    
    // MARK: - Actions
    @MainActor
    func generateWithAI() async {
        isGenerating = true
        errorMessage = nil
        
        do {
            let generated = try await aiService.generatePersona()
            name = generated.name
            selectedTraits = Set(generated.traits)
            backstory = generated.backstory
            interests = generated.interests
            
            // Set voice style based on traits (simple heuristic)
            if generated.traits.contains("poetic") || generated.traits.contains("philosophical") {
                voiceStyle = .poetic
            } else if generated.traits.contains("technical") || generated.traits.contains("analytical") {
                voiceStyle = .technical
            } else if generated.traits.contains("humorous") || generated.traits.contains("witty") {
                voiceStyle = .humorous
            } else {
                voiceStyle = .casual
            }
        } catch {
            if let aiError = error as? AIError, aiError == .noAPIKey {
                isAPIKeyError = true
                errorMessage = "请先设置 API Key 才能使用 AI 功能"
            } else {
                isAPIKeyError = false
                errorMessage = error.localizedDescription
            }
        }
        
        isGenerating = false
    }
    
    func createPersona() -> Persona {
        let persona = Persona(
            name: name,
            personalityTraits: Array(selectedTraits),
            backstory: backstory,
            voiceStyle: voiceStyle.rawValue,
            interests: interests,
            isUserOwned: true
        )
        
        if let avatarImage = avatarImage {
            persona.avatarImageData = avatarImage.pngData()
        }
        
        modelContext.insert(persona)
        return persona
    }
    
    func reset() {
        name = ""
        selectedTraits = []
        backstory = ""
        voiceStyle = .casual
        interests = []
        avatarImage = nil
        selectedPhoto = nil
        errorMessage = nil
        isAPIKeyError = false
    }
    
    @MainActor
    func loadPhoto() async {
        guard let selectedPhoto = selectedPhoto else { return }
        
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                avatarImage = image
            }
        } catch {
            errorMessage = "Failed to load image: \(error.localizedDescription)"
        }
    }
}

