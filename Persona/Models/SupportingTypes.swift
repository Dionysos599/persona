import Foundation

enum VoiceStyle: String, Codable, CaseIterable {
    case formal
    case casual
    case poetic
    case technical
    case humorous

    var displayName: String {
        switch self {
        case .formal: return "正式"
        case .casual: return "随意"
        case .poetic: return "诗意"
        case .technical: return "技术"
        case .humorous: return "幽默"
        }
    }
}

enum PersonalityTrait: String, Codable, CaseIterable {
    case creative
    case analytical
    case empathetic
    case adventurous
    case philosophical
    case witty
    case calm
    case energetic
}
