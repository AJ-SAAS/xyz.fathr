import SwiftUI

extension Color {

    // MARK: - Hex initializer (available app-wide)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }

    // MARK: - Core Brand
    static let fathrLime    = Color(red: 0.784, green: 0.945, blue: 0.208)
    static let fathrDark    = Color(red: 0.102, green: 0.102, blue: 0.102)
    static let fathrGreen   = Color(red: 0.114, green: 0.620, blue: 0.459)

    // MARK: - Neutrals / Text
    static let fathrBlack   = Color(hex: "#0D0D0F")
    static let fathrText    = Color(hex: "#1A1A1F")
    static let fathrSub     = Color(hex: "#4A5268")
    static let fathrMuted   = Color(red: 0.373, green: 0.369, blue: 0.353)

    // MARK: - Surfaces
    static let fathrSurface = Color(red: 0.961, green: 0.961, blue: 0.941)
    static let fathrOff     = Color(hex: "#F7F8FA")
    static let fathrBorder  = Color(red: 0.878, green: 0.878, blue: 0.863)

    // MARK: - Blue Theme
    static let fathrBlue      = Color(hex: "#1A4FCC")
    static let fathrBlueMid   = Color(hex: "#C2D1F7")
    static let fathrBlueLight = Color(hex: "#EEF3FF")

    // MARK: - States
    static let fathrSuccess   = Color(hex: "#1A7A45")
    static let fathrDanger    = Color(hex: "#B03030")
    static let fathrDangerBg  = Color(hex: "#FFECEC")
}
