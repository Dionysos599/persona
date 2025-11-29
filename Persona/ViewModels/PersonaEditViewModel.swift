import SwiftUI
import SwiftData
import PhotosUI

@Observable
final class PersonaEditViewModel {
    // State
    var name: String
    var selectedTraits: Set<String>
    var backstory: String
    var voiceStyle: VoiceStyle
    var interests: [String]
    var avatarImage: UIImage?
    var selectedPhoto: PhotosPickerItem?
    
    var isSaving: Bool = false
    var errorMessage: String?
    
    // Dependencies
    private let persona: Persona
    private let modelContext: ModelContext
    
    init(persona: Persona, modelContext: ModelContext) {
        self.persona = persona
        self.modelContext = modelContext
        
        self.name = persona.name
        self.selectedTraits = Set(persona.personalityTraits)
        self.backstory = persona.backstory
        self.voiceStyle = VoiceStyle(rawValue: persona.voiceStyle) ?? .casual
        self.interests = persona.interests
        
        if let imageData = persona.avatarImageData,
           let image = UIImage(data: imageData) {
            self.avatarImage = image
        }
    }
    
    // Computed Properties
    var isValid: Bool {
        !name.isEmpty && !selectedTraits.isEmpty && !backstory.isEmpty
    }
    
    var hasChanges: Bool {
        name != persona.name ||
        selectedTraits != Set(persona.personalityTraits) ||
        backstory != persona.backstory ||
        voiceStyle.rawValue != persona.voiceStyle ||
        interests != persona.interests ||
        selectedPhoto != nil
    }
    
    // Actions
    func save() {
        isSaving = true
        errorMessage = nil
        
        persona.name = name
        persona.personalityTraits = Array(selectedTraits)
        persona.backstory = backstory
        persona.voiceStyle = voiceStyle.rawValue
        persona.interests = interests
        
        if let avatarImage = avatarImage {
            persona.avatarImageData = avatarImage.pngData()
        }
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSaving = false
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

