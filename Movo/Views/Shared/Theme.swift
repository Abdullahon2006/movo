import SwiftUI
import UIKit

extension Color {
    static let movoBackground = Color(hex: "#0B0B0D")
    static let movoPanel = Color(hex: "#17171C")
    static let movoPanelBorder = Color(hex: "#2C2C33")
    static let movoVolt = Color(hex: "#C6FF00")
    static let movoCoral = Color(hex: "#FF6B5E")
    static let movoSteel = Color(hex: "#5B8DEF")
    static let movoTextPrimary = Color.white
    static let movoTextSecondary = Color(hex: "#93939C")
}

extension Font {
    /// Bold poster font for headers. Falls back to a system heavy weight until Anton-Regular.ttf is bundled.
    static func movoHeader(_ size: CGFloat) -> Font {
        guard UIFont(name: "Anton-Regular", size: size) != nil else {
            return .system(size: size, weight: .black, design: .default)
        }
        return .custom("Anton-Regular", size: size)
    }

    /// Scoreboard-style monospace for stats. Falls back to system monospaced until JetBrainsMono-Regular.ttf is bundled.
    static func movoMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        guard UIFont(name: "JetBrainsMono-Regular", size: size) != nil else {
            return .system(size: size, weight: weight, design: .monospaced)
        }
        return .custom("JetBrainsMono-Regular", size: size)
    }
}
