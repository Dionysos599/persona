import SwiftUI

struct PersonaAvatarView: View {
    let persona: Persona?
    var size: CGFloat = Constants.AvatarSize.large
    var showBorder: Bool = true
    
    var body: some View {
        Group {
            if let imageData = persona?.avatarImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            if showBorder {
                Circle()
                    .stroke(Color.personaGradient, lineWidth: 2)
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        PersonaAvatarView(persona: nil, size: 40)
        PersonaAvatarView(persona: nil, size: 60)
        PersonaAvatarView(persona: nil, size: 80, showBorder: false)
    }
    .padding()
}

