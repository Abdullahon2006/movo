import Foundation

enum Stage: String, CaseIterable, Codable {
    case rookie
    case grinder
    case baller
    case beast
    case legend

    /// Total points required to reach this stage.
    var threshold: Int {
        switch self {
        case .rookie: return 0
        case .grinder: return 150
        case .baller: return 400
        case .beast: return 800
        case .legend: return 1500
        }
    }

    var displayName: String {
        switch self {
        case .rookie: return "Rookie"
        case .grinder: return "Grinder"
        case .baller: return "Baller"
        case .beast: return "Beast"
        case .legend: return "Legend"
        }
    }

    static func current(for points: Int) -> Stage {
        allCases.reversed().first { points >= $0.threshold } ?? .rookie
    }

    var next: Stage? {
        let all = Stage.allCases
        guard let idx = all.firstIndex(of: self), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }

    var hasHeadband: Bool {
        let all = Stage.allCases
        guard let mine = all.firstIndex(of: self), let baller = all.firstIndex(of: .baller) else { return false }
        return mine >= baller
    }

    var hasCape: Bool {
        self == .legend
    }
}
