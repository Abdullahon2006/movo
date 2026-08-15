import Foundation

/// The kind of movement, which decides whether the logged amount is reps, seconds or kilometres.
enum MoveKind: String, Codable {
    case reps
    case hold
    case flow
    case dist
}

/// Quick-log exercises shown on the main "Log a workout" grid.
enum Exercise: String, CaseIterable, Codable, Identifiable {
    case pushUps
    case squats
    case jumpingJacks
    case plank
    case run
    case walk

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pushUps: return "Push-ups"
        case .squats: return "Squats"
        case .jumpingJacks: return "Jumping jacks"
        case .plank: return "Plank"
        case .run: return "Run"
        case .walk: return "Walk"
        }
    }

    var symbolName: String {
        switch self {
        case .pushUps: return "figure.strengthtraining.functional"
        case .squats: return "figure.squats"
        case .jumpingJacks: return "figure.jumprope"
        case .plank: return "figure.core.training"
        case .run: return "figure.run"
        case .walk: return "figure.walk"
        }
    }

    var kind: MoveKind {
        switch self {
        case .pushUps, .squats, .jumpingJacks: return .reps
        case .plank: return .hold
        case .run, .walk: return .dist
        }
    }

    /// Points per rep, per 10 seconds (hold), or per kilometre (dist) — the MOVES weight table.
    var weight: Double {
        switch self {
        case .pushUps: return 2.0
        case .squats: return 1.5
        case .jumpingJacks: return 1.0
        case .plank: return 3.0
        case .run: return 40.0
        case .walk: return 15.0
        }
    }

    var unitLabel: String {
        switch kind {
        case .reps: return "each"
        case .hold: return "10s"
        case .flow: return "10s"
        case .dist: return "km"
        }
    }

    var weightLabel: String {
        switch kind {
        case .reps: return "\(weight.trimmedString) \(weight == 1 ? "pt" : "pts") each"
        case .hold, .flow: return "\(weight.trimmedString) pts / 10s"
        case .dist: return "\(weight.trimmedString) pts / km"
        }
    }

    /// The default step size shown on the stepper for this exercise.
    var step: Double {
        switch kind {
        case .reps: return 1
        case .hold, .flow: return 10
        case .dist: return 0.1
        }
    }

    var defaultAmount: Double {
        switch kind {
        case .reps: return 15
        case .hold, .flow: return 30
        case .dist: return 1.0
        }
    }

    /// Raw points before streak bonus / character multiplier are applied.
    func basePoints(for amount: Double) -> Double {
        switch kind {
        case .reps: return amount * weight
        case .hold, .flow: return (amount / 10.0) * weight
        case .dist: return amount * weight
        }
    }
}

extension Double {
    /// Formats "1.5" as "1.5" and "2.0" as "2".
    var trimmedString: String {
        self.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(format: "%.1f", self)
    }
}
