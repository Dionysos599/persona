import SwiftUI
import SwiftData

struct PersonaEditView: View {
    let persona: Persona
    
    var body: some View {
        VStack {
            Text("Edit Persona")
                .font(.title2)
                .fontWeight(.semibold)
            Text(persona.name)
                .font(.title)
                .padding(.top, 8)
            Text("Edit View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .navigationTitle("编辑 Persona")
        .navigationBarTitleDisplayMode(.inline)
    }
}

