import SwiftUI

extension Color {
    static let movoCanvas = Color(hex: "#141712")
    static let movoSurfaceDark = Color(hex: "#282E29")
    static let movoSurfaceDarkAlt = Color(hex: "#1D211C")
    static let movoPaper = Color(hex: "#F3F4F0")
    static let movoLime = Color(hex: "#C6F24E")
    static let movoAmber = Color(hex: "#FFB13D")
    static let movoBlue = Color(hex: "#57B4FF")
    static let movoPink = Color(hex: "#FF7FC4")
    static let movoTextDark = Color(hex: "#12140F")
    static let movoTextSecondaryLight = Color(hex: "#6B7268")
    static let movoTextSecondaryDark = Color(hex: "#9AA39A")
}

/// Resolves the design-system palette from the ambient color scheme, which `RootView` already
/// pins to the user's theme choice (dark / light / auto) via `.preferredColorScheme`.
extension ColorScheme {
    var movoBackground: Color { self == .dark ? .movoCanvas : .movoPaper }
    var movoSurface: Color { self == .dark ? .movoSurfaceDark : .white }
    var movoSurfaceAlt: Color { self == .dark ? .movoSurfaceDarkAlt : Color(hex: "#EAEBE5") }
    var movoTextPrimary: Color { self == .dark ? .white : .movoTextDark }
    var movoTextSecondary: Color { self == .dark ? .movoTextSecondaryDark : .movoTextSecondaryLight }
    var movoBorder: Color { self == .dark ? Color.white.opacity(0.07) : Color.black.opacity(0.07) }
    var movoShadow: Color { self == .dark ? Color.clear : Color.black.opacity(0.05) }
}

enum MovoMetrics {
    static let cardRadius: CGFloat = 24
    static let smallRadius: CGFloat = 16
    static let chipRadius: CGFloat = 14
    static let pillRadius: CGFloat = 999
    static let screenPadding: CGFloat = 20
}

extension Font {
    /// Space Grotesk 700 stand-in — headings, numbers, character names.
    static func movoDisplay(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// DM Sans stand-in — body copy, labels, buttons.
    static func movoBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}
