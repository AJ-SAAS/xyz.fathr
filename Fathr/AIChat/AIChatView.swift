import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var showDisclaimerPopup = true

    var body: some View {
        VStack(spacing: 0) {
            topBar
            chatScrollView
            Divider().background(Color.gray.opacity(0.3))
            inputBar
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("")
        .onAppear {
            if viewModel.messages.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.isLoading = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {  // FIXED: DispatchQueue
                    let welcome = """
                    Hi! I’m your dedicated Fathr Wellness Coach.

                    I can help you with:
                    • Understand sperm test results (motility, count, etc.)
                    • Boost chances with simple diet & lifestyle tweaks
                    • Lifestyle & nutrition ideas
                    • Motivation & partner support

                    General tips only — talk to your doctor.

                    What’s on your mind?
                    """
                    viewModel.messages.append(AIChatViewModel.Message(text: welcome, isUser: false))
                    viewModel.isLoading = false
                }
            }
        }
        .alert("Important", isPresented: $showDisclaimerPopup) {
            Button("Got it") {
                UserDefaults.standard.set(true, forKey: "DisclaimerAccepted")
            }
        } message: {
            Text("I am **not a doctor**. I provide **general wellness education only**.\n\n• No medical advice\n• No diagnosis\n• No treatment\n\nAlways consult a healthcare professional.")
        }
        .onAppear {
            let accepted = UserDefaults.standard.bool(forKey: "DisclaimerAccepted")
            showDisclaimerPopup = !accepted
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Text("Fathr Wellness Coach")
                    .font(.headline)
                    .foregroundColor(.black)
                HStack(spacing: 6) {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.green)
                    Text("Online")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image("wellnesscoach")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
    }

    // MARK: - Chat Scroll View (with pinned disclaimer)
    private var chatScrollView: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    // PINNED DISCLAIMER — Always at top
                    HStack {
                        Image(systemName: "exclamationmark.shield")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("I am **not a doctor**. This is **general wellness education only**. Always consult a healthcare professional.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .id("pinnedDisclaimer")

                    // Chat messages
                    ForEach(viewModel.messages) { message in
                        ChatMessageView(message: message)
                            .id(message.id)
                    }

                    if viewModel.isLoading {
                        HStack(alignment: .top, spacing: 8) {
                            Image("wellnesscoach")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            TypingIndicator()
                                .frame(maxWidth: 250, alignment: .leading)
                            Spacer()
                        }
                        .id("typingIndicator")
                    }
                }
                .padding(.bottom, 8)
            }
            .onChange(of: viewModel.messages.count) { _ in
                withAnimation {
                    if let lastMessageID = viewModel.messages.last?.id {
                        scrollViewProxy.scrollTo(lastMessageID, anchor: .bottom)
                    } else if viewModel.isLoading {
                        scrollViewProxy.scrollTo("typingIndicator", anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isLoading) { isLoading in
                if isLoading {
                    withAnimation {
                        scrollViewProxy.scrollTo("typingIndicator", anchor: .bottom)
                    }
                }
            }
            .onTapGesture { isInputFocused = false }
        }
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(alignment: .center, spacing: 8) {
            TextField("Ask anything about fertility...", text: $viewModel.inputText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .foregroundColor(.black)
                .frame(minHeight: 48)
                .padding(.horizontal)
                .focused($isInputFocused)
            
            Button {
                viewModel.sendMessage()
                isInputFocused = false
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .frame(width: 48, height: 48)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

// MARK: - Single Chat Message View (NO repeated disclaimer)
struct ChatMessageView: View {
    let message: AIChatViewModel.Message
    @State private var showReport = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .font(.system(size: 17))
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.black)
                        .frame(maxWidth: 250, alignment: .trailing)
                }
            } else {
                Image("wellnesscoach")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(.system(size: 17))
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.black)
                        .frame(maxWidth: 250, alignment: .leading)
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation { showReport.toggle() }
                        }

                    if showReport {
                        HStack {
                            Button("Report") {
                                print("REPORT: \(message.text)")
                                showReport = false
                            }
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            Spacer()
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showReport)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var dotOpacity1: Double = 0.3
    @State private var dotOpacity2: Double = 0.3
    @State private var dotOpacity3: Double = 0.3

    var body: some View {
        HStack(spacing: 4) {
            Circle().frame(width: 8, height: 8).foregroundColor(.blue).opacity(dotOpacity1)
            Circle().frame(width: 8, height: 8).foregroundColor(.blue).opacity(dotOpacity2)
            Circle().frame(width: 8, height: 8).foregroundColor(.blue).opacity(dotOpacity3)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.0)) { dotOpacity1 = 1.0 }
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.2)) { dotOpacity2 = 1.0 }
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.4)) { dotOpacity3 = 1.0 }
        }
    }
}

#Preview {
    AIChatView()
}
