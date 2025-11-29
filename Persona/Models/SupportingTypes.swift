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
    
    var displayName: String {
        switch self {
        case .creative: return "创意"
        case .analytical: return "分析"
        case .empathetic: return "共情"
        case .adventurous: return "冒险"
        case .philosophical: return "哲学"
        case .witty: return "机智"
        case .calm: return "冷静"
        case .energetic: return "活力"
        }
    }
}
