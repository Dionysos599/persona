import SwiftUI

extension Color {

    // Brand Colors

    /** Primary brand color - Indigo (#4F46E5) */
    static let personaPrimary = Color(red: 79/255, green: 70/255, blue: 229/255)

    /** Secondary brand color - Purple (#7C3AED) */
    static let personaSecondary = Color(red: 124/255, green: 58/255, blue: 237/255)

    /** Accent color for highlights */
    static let personaAccent = Color(red: 99/255, green: 102/255, blue: 241/255)

    // Gradients

    /** Primary gradient for AI-related elements */
    static let personaGradient = LinearGradient(
        colors: [.personaPrimary, .personaSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /** Subtle gradient for backgrounds */
    static let subtleGradient = LinearGradient(
        colors: [
            Color(red: 79/255, green: 70/255, blue: 229/255, opacity: 0.1),
            Color(red: 124/255, green: 58/255, blue: 237/255, opacity: 0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Semantic Colors

    /** Card background color (adapts to light/dark mode) */
    static let cardBackground = Color(.systemBackground)

    /** Secondary background color */
    static let secondaryBackground = Color(.secondarySystemBackground)

    /** Tertiary background color */
    static let tertiaryBackground = Color(.tertiarySystemBackground)

    /** Primary text color */
    static let primaryText = Color(.label)

    /** Secondary text color */
    static let secondaryText = Color(.secondaryLabel)

    /** Tertiary text color */
    static let tertiaryText = Color(.tertiaryLabel)

    // Status Colors

    /** Success/positive state color */
    static let success = Color.green

    /** Warning/caution state color */
    static let warning = Color.orange

    /** Error/negative state color */
    static let error = Color.red

    /** Info/neutral state color */
    static let info = Color.blue

    // Message Bubble Colors

    /** User message bubble background */
    static let userMessageBackground = personaPrimary

    /** User message text color */
    static let userMessageText = Color.white

    /** AI message bubble background */
    static let aiMessageBackground = Color(.systemGray5)

    /** AI message text color */
    static let aiMessageText = Color.primaryText

    // Interactive States

    /** Like/favorite color (active state) */
    static let liked = Color.pink

    /** Follow button color */
    static let followButton = personaPrimary

    /** Unfollow button color */
    static let unfollowButton = Color(.systemGray3)

    // Helper Methods

    /** Creates a color from hex string */
    static func hex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 6:
            (r, g, b, a) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// ShapeStyle Extension for Gradients

extension ShapeStyle where Self == LinearGradient {
    /** Primary persona gradient as ShapeStyle */
    static var personaGradient: LinearGradient {
        LinearGradient(
            colors: [.personaPrimary, .personaSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
