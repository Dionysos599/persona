import SwiftUI

struct PersonaCreationView: View {
    var body: some View {
        VStack {
            Text("Create Persona")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Persona Creation View - Coming Soon")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .navigationTitle("创建 Persona")
        .navigationBarTitleDisplayMode(.inline)
    }
}

