import SwiftUI

// MARK: - Typography
extension Font {
    static func playfair(_ size: CGFloat) -> Font {
        .custom("Georgia-Bold", size: size)
    }
    static func playfairItalic(_ size: CGFloat) -> Font {
        .custom("Georgia-Italic", size: size)
    }
}

// MARK: - Stagger Reveal Modifier
struct StaggerReveal: ViewModifier {
    let index: Int
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 16)
            .onAppear {
                withAnimation(.easeOut(duration: 0.45).delay(Double(index) * 0.12)) {
                    visible = true
                }
            }
    }
}

extension View {
    func staggerReveal(_ index: Int) -> some View {
        modifier(StaggerReveal(index: index))
    }
}

// MARK: - Onboarding Dots
struct OnboardingDots: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i == current ? Color.fathrBlue : Color.fathrBlueMid)
                    .frame(width: i == current ? 26 : 6, height: 6)
            }
        }
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let perform: () -> Void

    init(_ title: String, perform: @escaping () -> Void) {
        self.title = title
        self.perform = perform
    }

    var body: some View {
        Button(action: perform) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.fathrBlue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Skip Link
struct SkipLink: View {
    let perform: () -> Void

    var body: some View {
        Button(action: perform) {
            Text("Skip intro")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.fathrMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
    }
}

// MARK: - Next Button
struct NextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.fathrBlue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Pain Point Row
struct PainPointRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.fathrDanger)
                .padding(.top, 1)

            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.fathrDanger)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color.fathrDangerBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.playfair(30))
                .foregroundColor(Color.fathrBlue)
                .minimumScaleFactor(0.8)
            Text(subtitle)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.fathrBlueLight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Timeline Row
struct TimelineRow: View {
    let day: String
    let description: String
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.fathrBlue)
                    .frame(width: 12, height: 12)
                    .padding(.top, 3)

                if !isLast {
                    Rectangle()
                        .fill(Color.fathrBlueMid)
                        .frame(width: 2)
                        .frame(minHeight: 44)
                }
            }
            .frame(width: 28, alignment: .top)

            VStack(alignment: .leading, spacing: 3) {
                Text(day)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.fathrBlue)
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.fathrSub)
            }
            .padding(.bottom, isLast ? 0 : 28)
        }
    }
}

// MARK: - Before After Card
struct BeforeAfterCard: View {
    let label: String
    let labelColor: Color
    let items: [String]
    let isAfter: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(labelColor)
                .kerning(0.8)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(isAfter ? Color.fathrSuccess : Color.fathrMuted.opacity(0.5))
                        .frame(width: 6, height: 6)
                        .padding(.top, 5)
                    Text(item)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(isAfter ? Color.fathrSub : Color.fathrMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.fathrOff)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.fathrBorder, lineWidth: 1)
        )
    }
}

// MARK: - FAQ Row
struct FAQRow: View {
    let question: String
    let answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(question)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.fathrBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Color(hex: "#F0F4FF"))

            Divider()
                .background(Color.fathrBorder)

            Text(answer)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.fathrSub)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true) // ✅ FIX
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.fathrBorder, lineWidth: 1)
        )
    }
}

// MARK: - Testimonial Card
struct TestimonialCard: View {
    let quote: String
    let name: String
    let result: String
    let initials: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(Color.fathrBlue)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 14) {
                Text(quote)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(Color.fathrSub)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .italic()

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.fathrBlueLight)
                            .frame(width: 40, height: 40)
                        Text(initials)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.fathrBlue)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(name)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color.fathrMuted)
                        Text(result)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.fathrSuccess)
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.fathrOff)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.fathrBorder, lineWidth: 1)
        )
    }
}

// MARK: - Option Row
struct OptionRow: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? Color.fathrBlue : Color.fathrBorder,
                            lineWidth: isSelected ? 2 : 1.5
                        )
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(Color.fathrBlue)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(text)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.fathrBlack : Color.fathrSub)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(isSelected ? Color.fathrBlueLight : Color.fathrOff)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.fathrBlue : Color.fathrBorder,
                            lineWidth: isSelected ? 1.5 : 1)
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
