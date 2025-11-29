import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var router = Router()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            // Feed Tab
            NavigationStack(path: $router.feedPath) {
                FeedView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label("广场", systemImage: "rectangle.grid.1x2")
            }
            .tag(Router.Tab.feed)
            
            // Chat Tab
            NavigationStack(path: $router.chatPath) {
                ChatListView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label("对话", systemImage: "bubble.left.and.bubble.right")
            }
            .tag(Router.Tab.chat)
            
            // Persona Tab
            NavigationStack(path: $router.profilePath) {
                MyPersonaView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label("Persona", systemImage: "person.2")
            }
            .tag(Router.Tab.persona)
            
            // My Profile Tab
            NavigationStack(path: $router.settingsPath) {
                SettingsView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .tabItem {
                Label("我的", systemImage: "person.crop.circle")
            }
            .tag(Router.Tab.myProfile)
        }
        .environment(router)
        .onChange(of: router.selectedTab) { oldValue, newValue in
            // Reset navigation path when switching to "Persona" tab
            if newValue == .persona {
                router.profilePath = NavigationPath()
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .feed:
            FeedView()
        case .postDetail(let post):
            PostDetailView(post: post)
        case .personaProfile(let persona):
            PersonaDetailView(persona: persona)
        case .createPersona:
            PersonaCreationView(aiService: AIService.shared)
        case .editPersona(let persona):
            PersonaEditView(persona: persona)
        case .myPersonaDetail(let persona):
            PersonaDetailView(persona: persona)  // Same view as personaProfile, handles both cases
        case .chatList:
            ChatListView()
        case .chat(let conversation):
            ChatView(conversation: conversation)
        case .privateChat(let persona):
            PrivateChatView(persona: persona)
        case .settings:
            SettingsView()
        case .apiSettings:
            APISettingsView()
        case .followingList:
            FollowingListView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Persona.self, Post.self, Conversation.self, Message.self])
}

