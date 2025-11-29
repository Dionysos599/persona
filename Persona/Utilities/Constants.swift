import Foundation
import SwiftUI

/// App-wide constants for configuration, design system, and API settings
enum Constants {

    // MARK: - API Configuration
    enum API {
        static let defaultBaseURL = "https://api.openai.com/v1"
        static let defaultModel = "gpt-4o"
        static let defaultTemperature = 0.7
        static let defaultMaxTokens = 1000
        static let requestTimeout: TimeInterval = 60
        
        // MARK: - Model Configurations
        struct ModelConfig {
            let modelID: String
            let displayName: String
            let baseURL: String
        }
        
        static let modelConfigs: [String: ModelConfig] = [
            // OpenAI Models
            "gpt-4o": ModelConfig(
                modelID: "gpt-4o",
                displayName: "GPT-4o",
                baseURL: "https://api.openai.com/v1"
            ),
            "gpt-4-turbo": ModelConfig(
                modelID: "gpt-4-turbo",
                displayName: "GPT-4 Turbo",
                baseURL: "https://api.openai.com/v1"
            ),
            "gpt-3.5-turbo": ModelConfig(
                modelID: "gpt-3.5-turbo",
                displayName: "GPT-3.5 Turbo",
                baseURL: "https://api.openai.com/v1"
            ),
            // Anthropic Models
            "claude-3-5-sonnet-20241022": ModelConfig(
                modelID: "claude-3-5-sonnet-20241022",
                displayName: "Claude 3.5 Sonnet",
                baseURL: "https://api.anthropic.com/v1"
            ),
            // Qwen Models
            "qwen-turbo": ModelConfig(
                modelID: "qwen-turbo",
                displayName: "Qwen Turbo",
                baseURL: "https://dashscope.aliyuncs.com/compatible-mode/v1"
            ),
            "qwen-plus": ModelConfig(
                modelID: "qwen-plus",
                displayName: "Qwen Plus",
                baseURL: "https://dashscope.aliyuncs.com/compatible-mode/v1"
            ),
            "qwen-max": ModelConfig(
                modelID: "qwen-max",
                displayName: "Qwen Max",
                baseURL: "https://dashscope.aliyuncs.com/compatible-mode/v1"
            ),
            // DeepSeek Models
            "deepseek-chat": ModelConfig(
                modelID: "deepseek-chat",
                displayName: "DeepSeek Chat",
                baseURL: "https://api.deepseek.com/v1"
            ),
            "deepseek-coder": ModelConfig(
                modelID: "deepseek-coder",
                displayName: "DeepSeek Coder",
                baseURL: "https://api.deepseek.com/v1"
            ),
            // Doubao Models
            "doubao-pro": ModelConfig(
                modelID: "doubao-pro",
                displayName: "Doubao Pro",
                baseURL: "https://ark.cn-beijing.volces.com/api/v3"
            ),
            "doubao-lite": ModelConfig(
                modelID: "doubao-lite",
                displayName: "Doubao Lite",
                baseURL: "https://ark.cn-beijing.volces.com/api/v3"
            )
        ]
        
        static func baseURL(for modelID: String) -> String? {
            return modelConfigs[modelID]?.baseURL
        }
    }

    // MARK: - Design System - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Design System - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let pill: CGFloat = 100
    }

    // MARK: - Design System - Shadows
    enum Shadow {
        static let color = Color.black.opacity(0.1)
        static let radius: CGFloat = 8
        static let x: CGFloat = 0
        static let y: CGFloat = 2
    }

    // MARK: - Design System - Avatar Sizes
    enum AvatarSize {
        static let small: CGFloat = 32
        static let medium: CGFloat = 44
        static let large: CGFloat = 60
        static let xLarge: CGFloat = 100
    }

    // MARK: - Animation
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
    }

    // MARK: - App Storage Keys
    enum StorageKeys {
        static let apiKey = "apiKey"
        static let apiBaseURL = "apiBaseURL"
        static let apiModel = "apiModel"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let preferLocalAI = "preferLocalAI"
    }

    // MARK: - Limits
    enum Limits {
        static let maxPersonalityTraits = 5
        static let maxInterests = 10
        static let maxBackstoryLength = 500
        static let maxPostLength = 500
        static let maxMessageLength = 1000
    }
}
