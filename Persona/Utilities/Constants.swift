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

    // MARK: - Mock Data (Development)
    enum MockData {
        static let isEnabled = true // Set to false for production
        static let samplePersonaCount = 5
        static let samplePostCount = 10
    }
}
