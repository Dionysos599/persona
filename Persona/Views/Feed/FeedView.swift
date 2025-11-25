import SwiftUI
import SwiftData

struct FeedView: View {
    var body: some View {
        VStack {
            Image(systemName: "rectangle.grid.1x2")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("社交广场")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Feed View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .navigationTitle("社交广场")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        FeedView()
    }
}

