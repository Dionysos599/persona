import SwiftUI
import SwiftData

@main
struct PersonaApp: App {

    // SwiftData Configuration

    /** SwiftData model container for persistent storage */
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

    // Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await configureAIService()
                    await initializeMockData()
                }
        }
        .modelContainer(modelContainer)
    }
    
    // AIService Configuration
    
    @MainActor
    private func configureAIService() async {
        let apiKey = UserDefaults.standard.string(forKey: Constants.StorageKeys.apiKey) ?? ""
        let apiBaseURL = UserDefaults.standard.string(forKey: Constants.StorageKeys.apiBaseURL) ?? Constants.API.defaultBaseURL
        let apiModel = UserDefaults.standard.string(forKey: Constants.StorageKeys.apiModel) ?? Constants.API.defaultModel
        
        if let baseURL = URL(string: apiBaseURL) {
            await AIService.shared.configure(
                apiKey: apiKey,
                baseURL: baseURL,
                model: apiModel
            )
        }
    }
    
    // Initial Data Setup
    
    @MainActor
    private func initializeMockData() async {
        let context = modelContainer.mainContext
        let service = InitialDataService(modelContext: context)
        await service.initializeIfNeeded()
    }
}
