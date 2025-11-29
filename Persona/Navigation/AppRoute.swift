import Foundation
import SwiftData

enum AppRoute: Hashable {
    case feed
    case postDetail(Post)
    
    case personaProfile(Persona)
    case createPersona
    case editPersona(Persona)
    case myPersonaDetail(Persona)
    
    case chatList
    case chat(Conversation)
    case privateChat(Persona)
    
    case settings
    case apiSettings
    case followingList
}

