import Foundation
import SwiftData

enum AppRoute: Hashable {
    // Feed routes
    case feed
    case postDetail(Post)
    
    // Persona routes
    case personaProfile(Persona)  // Profile view for any Persona (merged with myPersonaDetail)
    case createPersona
    case editPersona(Persona)
    case myPersonaDetail(Persona)  // Detail view for user's own Persona (also uses PersonaDetailView)
    
    // Chat routes
    case chatList
    case chat(Conversation)
    case privateChat(Persona)  // User's chat with their own Persona
    
    // Settings
    case settings
    case apiSettings
    case followingList  // List of followed Personas
}

