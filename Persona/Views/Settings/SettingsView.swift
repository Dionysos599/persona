import SwiftUI

struct SettingsView: View {
    @Environment(Router.self) private var router
    @State private var authService = AuthService.shared
    @State private var showLoginSheet = false
    
    var body: some View {
        List {
            Section {
                if authService.isLoggedIn, let user = authService.currentUser {
                    HStack(spacing: Constants.Spacing.md) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.personaPrimary)
                        
                        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                            Text(user.username)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("已登录")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("退出") {
                            authService.logout()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.red)
                    }
                    .padding(.vertical, Constants.Spacing.sm)
                } else {
                    HStack(spacing: Constants.Spacing.md) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                            Text("未登录")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("登录以获得更好的体验")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("登录") {
                            showLoginSheet = true
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.personaPrimary)
                    }
                    .padding(.vertical, Constants.Spacing.sm)
                }
            }
            
            Section("关注") {
                NavigationLink(value: AppRoute.followingList) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundStyle(Color.personaPrimary)
                        Text("关注列表")
                    }
                }
            }
            
            Section("AI 配置") {
                NavigationLink(value: AppRoute.apiSettings) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundStyle(Color.personaPrimary)
                        Text("API 设置")
                    }
                }
            }
            
            Section("关于") {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("构建")
                    Spacer()
                    Text("1")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                Text("Persona - 构建你的 AI 化身，定义下一代社交网络")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: AppRoute.self) { route in
            destinationView(for: route)
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .followingList:
            FollowingListView()
        case .apiSettings:
            APISettingsView()
        case .personaProfile(let persona):
            PersonaDetailView(persona: persona)
        default:
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(Router())
}

