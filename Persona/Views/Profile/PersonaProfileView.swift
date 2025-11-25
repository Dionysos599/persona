import SwiftUI
import SwiftData

struct PersonaProfileView: View {
    let persona: Persona
    
    var body: some View {
        VStack {
            Text("Persona Profile")
                .font(.title2)
                .fontWeight(.semibold)
            Text(persona.name)
                .font(.title)
                .padding(.top, 8)
            Text("Profile View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .navigationTitle(persona.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

