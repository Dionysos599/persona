import SwiftUI

struct APISettingsView: View {
    var body: some View {
        VStack {
            Text("API Settings")
                .font(.title2)
                .fontWeight(.semibold)
            Text("API Settings View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .navigationTitle("API 设置")
        .navigationBarTitleDisplayMode(.inline)
    }
}

