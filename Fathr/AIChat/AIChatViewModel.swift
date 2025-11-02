import Foundation

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isLoading = false

    struct Message: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
    }

    // MARK: - Send Message (No await needed)
    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // user message
        messages.append(Message(text: trimmed, isUser: true))
        inputText = ""
        isLoading = true

        OpenAIManager.ask(prompt: trimmed) { [weak self] reply in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let finalReply = reply?.trimmingCharacters(in: .whitespacesAndNewlines)
                    ?? "Sorry, I couldn't respond right now."
                self.messages.append(Message(text: finalReply, isUser: false))
                self.isLoading = false
            }
        }
    }
}
