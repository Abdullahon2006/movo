import SwiftUI
import UIKit

struct CharacterProfile: Codable, Equatable {
    var name: String
    var accent: AccentOption
    var totalPoints: Int
    var multiplier: Double
    var weeklyTarget: Int
    var ownedItemIDs: Set<String>
    var equippedBySlot: [String: String]

    static let empty = CharacterProfile(
        name: "",
        accent: .lime,
        totalPoints: 0,
        multiplier: 1.0,
        weeklyTarget: 3,
        ownedItemIDs: [],
        equippedBySlot: [:]
    )

    var stage: Stage { Stage.current(for: totalPoints) }

    /// Simple level ladder used purely to gate wardrobe unlocks — separate from the 5 evolution stages.
    var level: Int { CharacterProfile.level(forPoints: totalPoints) }

    static func level(forPoints points: Int) -> Int { min(20, 1 + points / 75) }

    var bodyColor: Color { accent.color }

    /// Progress (0...1) from the current stage's threshold to the next stage's threshold.
    var progressToNextStage: Double {
        guard let next = stage.next else { return 1.0 }
        let span = Double(next.threshold - stage.threshold)
        guard span > 0 else { return 1.0 }
        return min(1.0, max(0.0, Double(totalPoints - stage.threshold) / span))
    }

    var pointsToNextStage: Int {
        guard let next = stage.next else { return 0 }
        return max(0, next.threshold - totalPoints)
    }

    func isEquipped(_ item: CosmeticItem) -> Bool {
        equippedBySlot[item.slot.rawValue] == item.id
    }

    /// Free items (cost 0) become owned automatically the moment their level/stage gate is met.
    func isAutoUnlocked(_ item: CosmeticItem) -> Bool {
        guard item.costPts == 0 else { return false }
        let stageOk = !item.requiresChampion || stage == .champion
        return level >= item.minLevel && stageOk
    }

    func isOwned(_ item: CosmeticItem) -> Bool {
        ownedItemIDs.contains(item.id) || isAutoUnlocked(item)
    }

    func unlockState(for item: CosmeticItem) -> UnlockState {
        if isEquipped(item) { return .equipped }
        if isOwned(item) { return .owned }
        let levelOk = level >= item.minLevel
        let stageOk = !item.requiresChampion || stage == .champion
        guard levelOk && stageOk else { return .locked }
        return .purchasable
    }

    /// Progress (0...1) toward unlocking a still-locked item — by level, or by points toward
    /// Champion for stage-gated items like the crown.
    func unlockProgress(for item: CosmeticItem) -> Double {
        if item.requiresChampion {
            return min(1.0, Double(totalPoints) / Double(Stage.champion.threshold))
        }
        guard item.minLevel > 0 else { return 1.0 }
        return min(1.0, Double(level) / Double(item.minLevel))
    }

    /// The resolved gear rig for rendering: explicit equip choices win, otherwise falls back to
    /// the best owned item per slot so the character keeps gearing up automatically as it unlocks.
    func gear() -> GearSet {
        func resolvedID(for slot: CosmeticSlot) -> String? {
            if let chosen = equippedBySlot[slot.rawValue],
               let item = CosmeticItem.catalog.first(where: { $0.id == chosen }), isOwned(item) {
                return chosen
            }
            let owned = CosmeticItem.catalog.filter { $0.slot == slot && isOwned($0) }
            return owned.max(by: { $0.minLevel < $1.minLevel })?.id
        }

        let head = resolvedID(for: .head)
        let body = resolvedID(for: .body)
        let feet = resolvedID(for: .feet)

        return GearSet(
            headband: head == CosmeticItem.headband.id,
            tankTop: body == CosmeticItem.tankTop.id,
            goldBand: body == CosmeticItem.goldBand.id,
            crown: head == CosmeticItem.crown.id,
            cape: body == CosmeticItem.cape.id,
            runners: feet == CosmeticItem.runners.id
        )
    }
}

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        if hexString.count <= 6 {
            let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let b = Double(rgbValue & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b)
        } else {
            hexString = String(hexString.prefix(6))
            self.init(hex: hexString)
        }
    }

    func toHex() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else { return "#FFFFFF" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    /// A darker shade of this color, used for derived shading (shadows, straps) from a single base value.
    func darker(by amount: Double = 0.2) -> Color {
        let uic = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uic.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: min(1, s * 1.05), brightness: max(0, b * (1 - amount)), opacity: a)
    }

    /// A lighter shade of this color, used for derived highlights from a single base value.
    func lighter(by amount: Double = 0.2) -> Color {
        let uic = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uic.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: max(0, s * 0.85), brightness: min(1, b + (1 - b) * amount), opacity: a)
    }
}
