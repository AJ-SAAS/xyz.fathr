import SwiftUI

struct Question3View: View {
    @Binding var sleepHours: Double
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("How much sleep do you get per night?")
                .font(.headline)
                .accessibilityLabel("Question: How much sleep do you get per night?")

            Slider(value: $sleepHours, in: 4...10, step: 1)
                .accessibilityLabel("Sleep hours slider, current value \(Int(sleepHours)) hours")
            Text("\(Int(sleepHours)) hours")
                .accessibilityHidden(true)

            Button("Next") {
                onNext()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .accessibilityLabel("Continue to next step")
        }
        .padding()
    }
}

#Preview {
    Question3View(sleepHours: .constant(7.0), onNext: {})
}
