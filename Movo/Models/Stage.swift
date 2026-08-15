import Foundation

/// The five Movo evolution stages, gated purely by total points.
enum Stage: Int, CaseIterable, Codable, Comparable {
    case egg = 1
    case hatchling
    case rookie
    case athlete
    case champion

    /// Total points required to reach this stage.
    var threshold: Int {
        switch self {
        case .egg: return 0
        case .hatchling: return 100
        case .rookie: return 300
        case .athlete: return 700
        case .champion: return 1500
        }
    }

    var displayName: String {
        switch self {
        case .egg: return "Egg"
        case .hatchling: return "Hatchling"
        case .rookie: return "Rookie"
        case .athlete: return "Athlete"
        case .champion: return "Champion"
        }
    }

    static func current(for points: Int) -> Stage {
        allCases.reversed().first { points >= $0.threshold } ?? .egg
    }

    var next: Stage? {
        let all = Stage.allCases
        guard let idx = all.firstIndex(of: self), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }

    /// Points range label, e.g. "100 - 299 pts".
    var rangeLabel: String {
        if let next {
            return "\(threshold) - \(next.threshold - 1) pts"
        }
        return "\(threshold)+ pts"
    }

    var hasHeadband: Bool { self >= .rookie }
    var hasTankTop: Bool { self >= .rookie }
    var hasGoldBand: Bool { self == .champion }
    var hasCrown: Bool { self == .champion }
    var hasCape: Bool { self == .champion }

    /// Body mass multiplier used to scale the character silhouette.
    var massScale: Double {
        switch self {
        case .egg: return 1.0
        case .hatchling: return 1.08
        case .rookie: return 1.18
        case .athlete: return 1.3
        case .champion: return 1.45
        }
    }

    static func < (lhs: Stage, rhs: Stage) -> Bool { lhs.rawValue < rhs.rawValue }

    /// What gets called out in the level-up modal when this stage is newly reached.
    var levelUpRewards: [String] {
        switch self {
        case .egg: return []
        case .hatchling: return ["+ Mass", "New wobble"]
        case .rookie: return ["Headband", "Tank top"]
        case .athlete: return ["Runners", "+1 Arms"]
        case .champion: return ["Gold band", "Crown"]
        }
    }
}
