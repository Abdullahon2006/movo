import Foundation

/// Step 1 of onboarding — self-reported experience level. Sets the starting stage,
/// starting point balance and the point multiplier (fitter starters earn less per rep,
/// so nobody coasts straight to Champion).
enum ExperienceLevel: String, CaseIterable, Codable, Identifiable {
    case new
    case onoff
    case regular
    case serious
    case competing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .new: return "Just starting"
        case .onoff: return "On and off"
        case .regular: return "Regular"
        case .serious: return "Serious"
        case .competing: return "Competing"
        }
    }

    var subtitle: String {
        switch self {
        case .new: return "Little or no exercise right now"
        case .onoff: return "A walk here, a gym week there"
        case .regular: return "2-4 sessions most weeks"
        case .serious: return "5+ sessions, or training for something"
        case .competing: return "Club, league or coach involved"
        }
    }

    /// START = { level: (stage, points, multiplier) }
    var startStage: Stage {
        switch self {
        case .new: return .egg
        case .onoff: return .hatchling
        case .regular: return .rookie
        case .serious: return .athlete
        case .competing: return .champion
        }
    }

    var startPoints: Int { startStage.threshold }

    var multiplier: Double {
        switch self {
        case .new: return 1.0
        case .onoff: return 0.9
        case .regular: return 0.8
        case .serious: return 0.7
        case .competing: return 0.6
        }
    }
}

/// Step 2 of onboarding — which sports the user actually does. Decides which exercises
/// surface first when logging.
enum SportType: String, CaseIterable, Codable, Identifiable {
    case gym, running, football, basketball, swimming
    case homeWorkouts, cycling, yoga, walking, climbing, martialArts, dance

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gym: return "Gym"
        case .running: return "Running"
        case .football: return "Football"
        case .basketball: return "Basketball"
        case .swimming: return "Swimming"
        case .homeWorkouts: return "Home workouts"
        case .cycling: return "Cycling"
        case .yoga: return "Yoga"
        case .walking: return "Walking"
        case .climbing: return "Climbing"
        case .martialArts: return "Martial arts"
        case .dance: return "Dance"
        }
    }
}

/// Persisted answers collected across the 3-step onboarding flow.
struct OnboardingState: Codable, Equatable {
    var experience: ExperienceLevel = .regular
    var sports: Set<SportType> = [.gym, .running, .homeWorkouts]
    var sessionsPerWeek: Int = 3
    var startFromEggAnyway: Bool = false
    var isComplete: Bool = false

    /// The stage actually applied once onboarding finishes, honoring the "start from the egg anyway" override.
    var resolvedStartStage: Stage { startFromEggAnyway ? .egg : experience.startStage }
    var resolvedStartPoints: Int { startFromEggAnyway ? 0 : experience.startPoints }
    var resolvedMultiplier: Double { startFromEggAnyway ? 1.0 : experience.multiplier }
}
