import SwiftUI
import UIKit

struct CharacterProfile: Codable, Equatable {
    var name: String
    var bodyColorHex: String
    var outfitColorHex: String
    var totalPoints: Int

    static let empty = CharacterProfile(name: "", bodyColorHex: "#3DDC97", outfitColorHex: "#FF6B5E", totalPoints: 0)

    var stage: Stage { Stage.current(for: totalPoints) }

    var bodyColor: Color { Color(hex: bodyColorHex) }
    var outfitColor: Color { Color(hex: outfitColorHex) }

    /// Progress (0...1) from the current stage's threshold to the next stage's threshold.
    var progressToNextStage: Double {
        guard let next = stage.next else { return 1.0 }
        let span = Double(next.threshold - stage.threshold)
        guard span > 0 else { return 1.0 }
        return min(1.0, max(0.0, Double(totalPoints - stage.threshold) / span))
    }

    /// Overall growth scale (1.0...1.6) driving the character's muscle size, capped at the Legend threshold.
    var growthScale: Double {
        let capped = min(totalPoints, Stage.legend.threshold)
        let ratio = Double(capped) / Double(Stage.legend.threshold)
        return 1.0 + ratio * 0.6
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
}
