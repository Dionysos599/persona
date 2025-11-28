import SwiftUI

struct PersonalityPickerView: View {
    @Binding var selectedTraits: Set<String>
    
    let availableTraits = PersonalityTrait.allCases
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: Constants.Spacing.sm) {
            ForEach(availableTraits, id: \.self) { trait in
                TraitChip(
                    title: trait.rawValue.capitalized,
                    isSelected: selectedTraits.contains(trait.rawValue)
                ) {
                    if selectedTraits.contains(trait.rawValue) {
                        selectedTraits.remove(trait.rawValue)
                    } else {
                        selectedTraits.insert(trait.rawValue)
                    }
                }
            }
        }
    }
}

struct TraitChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(isSelected ? Color.personaPrimary : Color.secondaryBackground)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedTraits: Set<String> = ["creative", "witty"]
    
    return PersonalityPickerView(selectedTraits: $selectedTraits)
        .padding()
}

