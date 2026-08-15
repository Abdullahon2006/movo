import Foundation

enum CosmeticSlot: String, Codable, CaseIterable, Identifiable {
    case head, body, feet
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum UnlockState {
    case equipped
    case owned
    case purchasable
    case locked
}

struct CosmeticItem: Identifiable, Codable, Equatable {
    var id: String
    var slot: CosmeticSlot
    var name: String
    var costPts: Int
    var minLevel: Int
    var requiresChampion: Bool

    static let headband = CosmeticItem(id: "headband", slot: .head, name: "Headband", costPts: 0, minLevel: 3, requiresChampion: false)
    static let runners = CosmeticItem(id: "runners", slot: .feet, name: "Runners", costPts: 0, minLevel: 5, requiresChampion: false)
    static let tankTop = CosmeticItem(id: "tank_top", slot: .body, name: "Tank top", costPts: 0, minLevel: 5, requiresChampion: false)
    static let cape = CosmeticItem(id: "cape", slot: .body, name: "Cape", costPts: 400, minLevel: 12, requiresChampion: false)
    static let goldBand = CosmeticItem(id: "gold_band", slot: .body, name: "Gold band", costPts: 0, minLevel: 18, requiresChampion: false)
    static let crown = CosmeticItem(id: "crown", slot: .head, name: "Crown", costPts: 0, minLevel: 1, requiresChampion: true)

    static let catalog: [CosmeticItem] = [headband, runners, tankTop, cape, goldBand, crown]

    /// Level equivalent used only for ordering the unlock roadmap — stage-gated items (the crown)
    /// carry a placeholder `minLevel` since they're really gated by reaching Champion, so this
    /// substitutes the level a character would be at once they hit that stage's point threshold.
    var effectiveMinLevel: Int {
        requiresChampion ? max(minLevel, CharacterProfile.level(forPoints: Stage.champion.threshold)) : minLevel
    }
}

/// Lvl 3 / Lvl 5 / Lvl 8 / Lvl 12 / Lvl 18 / Champ — shown as the roadmap on the wardrobe screen.
/// Per the build spec, only the first two rows are actually wired to real items; the rest sell
/// the roadmap visually.
struct UnlockRung: Identifiable {
    var id: String { label }
    var label: String
    var description: String
}

enum UnlockLadder {
    static let rungs: [UnlockRung] = [
        UnlockRung(label: "Lvl 3", description: "Headband, 3 starter colors"),
        UnlockRung(label: "Lvl 5", description: "Runners, tank top"),
        UnlockRung(label: "Lvl 8", description: "Light theme, accent picker"),
        UnlockRung(label: "Lvl 12", description: "Cape, gym backdrop"),
        UnlockRung(label: "Lvl 18", description: "Gold band, rare color pack"),
        UnlockRung(label: "Champ", description: "Crown, victory animation")
    ]
}
