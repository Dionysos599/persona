import SwiftUI
import SwiftData

struct PrivateChatView: View {
    let persona: Persona
    
    var body: some View {
        VStack {
            Text("Private Chat")
                .font(.title2)
                .fontWeight(.semibold)
            Text("With \(persona.name)")
                .font(.title)
                .padding(.top, 8)
            Text("Private Chat View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .navigationTitle("与 \(persona.name) 私聊")
        .navigationBarTitleDisplayMode(.inline)
    }
}

