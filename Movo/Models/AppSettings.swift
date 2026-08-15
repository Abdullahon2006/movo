import SwiftUI

enum ThemeMode: String, Codable, CaseIterable, Identifiable {
    case dark, light, auto
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }

    func resolvedScheme(system: ColorScheme) -> ColorScheme {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .auto: return system
        }
    }
}

/// The accent color is the same value that tints the app chrome and the Movo's body —
/// one pick re-skins the whole product.
enum AccentOption: String, Codable, CaseIterable, Identifiable {
    case lime, amber, blue, pink, cream

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .lime: return Color(hex: "#C6F24E")
        case .amber: return Color(hex: "#FFB13D")
        case .blue: return Color(hex: "#57B4FF")
        case .pink: return Color(hex: "#FF7FC4")
        case .cream: return Color(hex: "#F3F4F0")
        }
    }

    /// Whether accent-colored text/icons need a black or white foreground to stay legible.
    var prefersDarkForeground: Bool {
        switch self {
        case .lime, .amber, .cream: return true
        case .blue, .pink: return false
        }
    }
}

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english, arabic, french, spanish

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        case .french: return "Français"
        case .spanish: return "Español"
        }
    }

    var isRTL: Bool { self == .arabic }
}

enum UnitSystem: String, Codable, CaseIterable, Identifiable {
    case metric, imperial
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

struct NudgeSettings: Codable, Equatable {
    var movoTalks: Bool = true
    var dailyCrewDrop: Bool = true
    var waterReminders: Bool = false
}

struct AppSettings: Codable, Equatable {
    var theme: ThemeMode = .dark
    var accent: AccentOption = .lime
    var language: AppLanguage = .english
    var units: UnitSystem = .metric
    var nudges = NudgeSettings()
}
