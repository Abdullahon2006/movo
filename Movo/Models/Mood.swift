import Foundation

/// The five Movo moods. Same head rig, swapped eyes/mouth — driven entirely by activity state.
enum Mood: String, CaseIterable, Codable {
    case happy
    case firedUp
    case wrecked
    case annoyed
    case sulking

    var displayName: String {
        switch self {
        case .happy: return "Happy"
        case .firedUp: return "Fired up"
        case .wrecked: return "Wrecked"
        case .annoyed: return "Annoyed"
        case .sulking: return "Sulking"
        }
    }

    /// Inputs used by `resolve` to pick a mood, in priority order:
    /// workout in progress -> fired_up
    /// logged < 2h ago -> wrecked
    /// idle >= 4 days -> sulking
    /// weekly target missed -> annoyed
    /// otherwise -> happy
    static func resolve(workoutInProgress: Bool, hoursSinceLastWorkout: Double?, idleDays: Int, weeklyTargetMet: Bool) -> Mood {
        if workoutInProgress { return .firedUp }
        if let hours = hoursSinceLastWorkout, hours < 2 { return .wrecked }
        if idleDays >= 4 { return .sulking }
        if !weeklyTargetMet { return .annoyed }
        return .happy
    }

    /// Contextual dialogue lines Movo might say while in this mood. `seed` selects
    /// deterministically so the line doesn't change on every SwiftUI re-render —
    /// callers should only bump the seed when the underlying event actually changes.
    func line(seed: Int) -> String {
        let lines: [String]
        switch self {
        case .happy:
            lines = ["That's four sessions this week. My arms are visibly bigger. Coincidence? No.",
                     "Streak's alive. Target's on track. I'm feeling myself.",
                     "Every session compounds. We're doing this."]
        case .firedUp:
            lines = ["I'm shaking. You're shaking. Let's finish this.",
                     "Mid-set, no mercy. Keep going.",
                     "This is the part where it counts."]
        case .wrecked:
            lines = ["Proud. Done. Don't talk to me for five minutes.",
                     "That one earned the cooldown. Breathe with me.",
                     "We left it all out there."]
        case .annoyed:
            lines = ["Target missed. I noticed. I'm not mad, I'm disappointed.",
                     "The crew drop came and went. So did my patience.",
                     "We had one job this week."]
        case .sulking:
            lines = ["I'm not angry. I'm just sitting here. Losing definition. Every day.",
                     "Color's draining out. So is my patience.",
                     "Six days. I'm counting."]
        }
        let idx = ((seed % lines.count) + lines.count) % lines.count
        return lines[idx]
    }
}
