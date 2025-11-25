import SwiftUI
import SwiftData

@main
struct PersonaApp: App {

    // MARK: - SwiftData Configuration

    /// SwiftData model container for persistent storage
    var modelContainer: ModelContainer = {
        let schema = Schema([
            Persona.self,
            Post.self,
            Conversation.self,
            Message.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
