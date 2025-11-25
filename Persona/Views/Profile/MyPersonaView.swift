import SwiftUI
import SwiftData

struct MyPersonaView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("我的 Persona")
                .font(.title2)
                .fontWeight(.semibold)
            Text("My Persona View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        MyPersonaView()
    }
}

