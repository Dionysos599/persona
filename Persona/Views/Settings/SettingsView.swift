import SwiftUI

struct SettingsView: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        List {
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
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .followingList:
            FollowingListView()
        case .apiSettings:
            APISettingsView()
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

