import SwiftUI
import SwiftData

struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        VStack {
            Text("Post Detail")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Post ID: \(post.id.uuidString.prefix(8))")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .navigationTitle("动态详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}

