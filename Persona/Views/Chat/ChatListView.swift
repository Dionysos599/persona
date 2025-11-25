import SwiftUI
import SwiftData

struct ChatListView: View {
    var body: some View {
        VStack {
            Image(systemName: "bubble.left.and.bubble.right")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("对话列表")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Chat List View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .navigationTitle("对话")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ChatListView()
    }
}

