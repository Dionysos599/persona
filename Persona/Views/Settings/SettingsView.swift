import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Image(systemName: "gearshape")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("设置")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Settings View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

