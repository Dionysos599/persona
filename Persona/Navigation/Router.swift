import SwiftUI
import SwiftData

@Observable
final class Router {
    var feedPath = NavigationPath()
    var chatPath = NavigationPath()
    var profilePath = NavigationPath()
    
    var selectedTab: Tab = .feed
    
    enum Tab: Hashable {
        case feed, chat, myPersona, settings
    }
    
    var settingsPath = NavigationPath()
    
    func navigate(to route: AppRoute) {
        switch selectedTab {
        case .feed:
            feedPath.append(route)
        case .chat:
            chatPath.append(route)
        case .myPersona:
            profilePath.append(route)
        case .settings:
            settingsPath.append(route)
        }
    }
    
    func pop() {
        switch selectedTab {
        case .feed:
            if !feedPath.isEmpty { feedPath.removeLast() }
        case .chat:
            if !chatPath.isEmpty { chatPath.removeLast() }
        case .myPersona:
            if !profilePath.isEmpty { profilePath.removeLast() }
        default:
            break
        }
    }
    
    func popToRoot() {
        switch selectedTab {
        case .feed:
            feedPath = NavigationPath()
        case .chat:
            chatPath = NavigationPath()
        case .myPersona:
            profilePath = NavigationPath()
        case .settings:
            settingsPath = NavigationPath()
        }
    }
}

