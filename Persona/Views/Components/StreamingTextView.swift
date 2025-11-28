import SwiftUI

struct StreamingTextView: View {
    let stream: AsyncThrowingStream<String, Error>
    let onComplete: ((String) -> Void)?
    
    @State private var displayedText = ""
    @State private var isComplete = false
    @State private var error: Error?
    
    init(stream: AsyncThrowingStream<String, Error>, onComplete: ((String) -> Void)? = nil) {
        self.stream = stream
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text(displayedText)
                .animation(.easeInOut(duration: 0.05), value: displayedText)
            
            if !isComplete && error == nil {
                TypingIndicator()
            }
            
            if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .task {
            do {
                for try await chunk in stream {
                    displayedText += chunk
                }
                isComplete = true
                onComplete?(displayedText)
            } catch {
                self.error = error
                isComplete = true
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var dotCount = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 6, height: 6)
                    .opacity(dotCount == index ? 1 : 0.3)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                dotCount = (dotCount + 1) % 3
            }
        }
    }
}

