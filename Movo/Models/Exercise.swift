import Foundation

enum Exercise: String, CaseIterable, Codable, Identifiable {
    case jumpingJacks
    case pushUps
    case squats
    case sitUps
    case running
    case stretching

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .jumpingJacks: return "Jumping Jacks"
        case .pushUps: return "Push-Ups"
        case .squats: return "Squats"
        case .sitUps: return "Sit-Ups"
        case .running: return "Running"
        case .stretching: return "Stretching"
        }
    }

    var symbolName: String {
        switch self {
        case .jumpingJacks: return "figure.jumprope"
        case .pushUps: return "figure.strengthtraining.functional"
        case .squats: return "figure.squats"
        case .sitUps: return "figure.core.training"
        case .running: return "figure.run"
        case .stretching: return "figure.flexibility"
        }
    }

    /// Whether this exercise is logged in reps or minutes.
    var unit: LogUnit {
        switch self {
        case .jumpingJacks, .pushUps, .squats, .sitUps: return .reps
        case .running, .stretching: return .minutes
        }
    }

    /// Points earned per single rep or per minute.
    var pointsPerUnit: Int {
        switch self {
        case .jumpingJacks: return 1
        case .pushUps: return 2
        case .squats: return 2
        case .sitUps: return 2
        case .running: return 5
        case .stretching: return 2
        }
    }

    func points(for amount: Int) -> Int {
        amount * pointsPerUnit
    }
}

enum LogUnit: String, Codable {
    case reps
    case minutes

    var shortLabel: String {
        switch self {
        case .reps: return "reps"
        case .minutes: return "min"
        }
    }
}
