import Foundation
import SwiftData

enum AppRoute: Hashable {
    // Feed routes
    case feed
    case postDetail(Post)
    
    // Persona routes
    case personaProfile(Persona)
    case createPersona
    case editPersona(Persona)
    
    // Chat routes
    case chatList
    case chat(Conversation)
    case privateChat(Persona)  // User's chat with their own Persona
    
    // Settings
    case settings
    case apiSettings
}

