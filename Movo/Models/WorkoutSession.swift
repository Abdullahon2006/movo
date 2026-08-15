import Foundation

enum SessionCategory: String, CaseIterable, Codable, Identifiable {
    case reps, holds, stretches
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .reps: return "Reps"
        case .holds: return "Holds"
        case .stretches: return "Stretches"
        }
    }
}

/// A single move inside a timed session — a hold, a stretch, or a rep block.
struct SessionMove: Identifiable, Codable, Equatable {
    var id: String { name }
    var name: String
    var kind: MoveKind
    var seconds: Int
    /// Points per 10 seconds for hold/flow moves.
    var weight: Double
    var cue: String
}

/// A pre-built session template, e.g. "Core burner".
struct WorkoutSessionTemplate: Identifiable, Codable, Equatable {
    var id: String { name }
    var name: String
    var category: SessionCategory
    var moves: [SessionMove]
    var summary: String

    var totalSeconds: Int { moves.reduce(0) { $0 + $1.seconds } }
    var totalMinutes: Int { max(1, Int((Double(totalSeconds) / 60.0).rounded())) }
    var estimatedPoints: Int {
        Int(moves.reduce(0.0) { $0 + (Double($1.seconds) / 10.0) * $1.weight }.rounded())
    }
}

enum SessionLibrary {
    static let coreBurner = WorkoutSessionTemplate(
        name: "Core burner",
        category: .holds,
        moves: [
            SessionMove(name: "Plank", kind: .hold, seconds: 40, weight: 3.0, cue: "Ribs down, glutes tight."),
            SessionMove(name: "Side plank — left", kind: .hold, seconds: 30, weight: 3.0, cue: "I'm shaking. You're shaking."),
            SessionMove(name: "Side plank — right", kind: .hold, seconds: 30, weight: 3.0, cue: "Stack the hips."),
            SessionMove(name: "Hollow hold", kind: .hold, seconds: 30, weight: 3.0, cue: "Lower back glued to the floor.")
        ],
        summary: "4 holds · 6 min · plank, side plank, hollow"
    )

    static let wallSitLadder = WorkoutSessionTemplate(
        name: "Wall sit ladder",
        category: .holds,
        moves: [
            SessionMove(name: "Wall sit", kind: .hold, seconds: 40, weight: 2.5, cue: "Knees at ninety."),
            SessionMove(name: "Wall sit", kind: .hold, seconds: 50, weight: 2.5, cue: "Don't creep up the wall."),
            SessionMove(name: "Wall sit", kind: .hold, seconds: 60, weight: 2.5, cue: "Last rung. Hold the line.")
        ],
        summary: "3 holds · 5 min · 40s / 50s / 60s"
    )

    static let squatHoldPulse = WorkoutSessionTemplate(
        name: "Squat hold + pulse",
        category: .holds,
        moves: [
            SessionMove(name: "Squat hold", kind: .hold, seconds: 40, weight: 2.5, cue: "Sit low, chest up."),
            SessionMove(name: "Squat pulse", kind: .hold, seconds: 30, weight: 2.5, cue: "Small pulses, stay low."),
            SessionMove(name: "Squat hold", kind: .hold, seconds: 40, weight: 2.5, cue: "Legs are shot. Good."),
            SessionMove(name: "Squat pulse", kind: .hold, seconds: 30, weight: 2.5, cue: "Last round.")
        ],
        summary: "4 rounds · 7 min · legs"
    )

    static let deskUnstiffener = WorkoutSessionTemplate(
        name: "Desk unstiffener",
        category: .holds,
        moves: [
            SessionMove(name: "Neck rolls", kind: .flow, seconds: 30, weight: 1.0, cue: "Slow circles both ways."),
            SessionMove(name: "Hip flexor lunge", kind: .flow, seconds: 45, weight: 1.0, cue: "Tuck the pelvis under."),
            SessionMove(name: "Hamstring reach", kind: .flow, seconds: 30, weight: 1.0, cue: "Breathe. Don't bounce."),
            SessionMove(name: "Chest opener", kind: .flow, seconds: 30, weight: 1.0, cue: "Roll the shoulders back."),
            SessionMove(name: "Shoulder rolls", kind: .flow, seconds: 30, weight: 1.0, cue: "Loosen it up."),
            SessionMove(name: "Child's pose", kind: .flow, seconds: 60, weight: 1.0, cue: "Sink your hips back.")
        ],
        summary: "6 stretches · 4 min · neck, hips, hamstrings"
    )

    static let pushUpLadder = WorkoutSessionTemplate(
        name: "Push-up ladder",
        category: .reps,
        moves: [
            SessionMove(name: "Push-ups", kind: .reps, seconds: 20, weight: 2.0, cue: "Elbows at 45."),
            SessionMove(name: "Rest", kind: .flow, seconds: 15, weight: 0, cue: "Shake it out."),
            SessionMove(name: "Push-ups", kind: .reps, seconds: 20, weight: 2.0, cue: "Same form, tired arms."),
            SessionMove(name: "Rest", kind: .flow, seconds: 15, weight: 0, cue: "Almost there."),
            SessionMove(name: "Push-ups", kind: .reps, seconds: 20, weight: 2.0, cue: "Empty the tank.")
        ],
        summary: "3 rounds · 3 min · chest, arms, core"
    )

    static let legDay = WorkoutSessionTemplate(
        name: "Squat & jack circuit",
        category: .reps,
        moves: [
            SessionMove(name: "Squats", kind: .reps, seconds: 30, weight: 1.5, cue: "Chest up, sit back."),
            SessionMove(name: "Jumping jacks", kind: .reps, seconds: 30, weight: 1.0, cue: "Full extension."),
            SessionMove(name: "Squats", kind: .reps, seconds: 30, weight: 1.5, cue: "Second round."),
            SessionMove(name: "Jumping jacks", kind: .reps, seconds: 30, weight: 1.0, cue: "Keep the pace.")
        ],
        summary: "4 rounds · 4 min · legs, cardio"
    )

    static let fullBodyFlow = WorkoutSessionTemplate(
        name: "Full-body flow",
        category: .stretches,
        moves: [
            SessionMove(name: "Cat-cow", kind: .flow, seconds: 40, weight: 1.0, cue: "Move with your breath."),
            SessionMove(name: "Downward dog", kind: .flow, seconds: 40, weight: 1.0, cue: "Push the floor away."),
            SessionMove(name: "Lunge twist", kind: .flow, seconds: 40, weight: 1.0, cue: "Rotate from the ribs."),
            SessionMove(name: "Standing forward fold", kind: .flow, seconds: 40, weight: 1.0, cue: "Let the head hang.")
        ],
        summary: "4 stretches · ~3 min · full body"
    )

    static let mobilityReset = WorkoutSessionTemplate(
        name: "Mobility reset",
        category: .stretches,
        moves: [
            SessionMove(name: "Hip circles", kind: .flow, seconds: 30, weight: 1.0, cue: "Both directions."),
            SessionMove(name: "Ankle rolls", kind: .flow, seconds: 30, weight: 1.0, cue: "Slow and controlled."),
            SessionMove(name: "Thread the needle", kind: .flow, seconds: 40, weight: 1.0, cue: "Rotate through the spine."),
            SessionMove(name: "Child's pose", kind: .flow, seconds: 60, weight: 1.0, cue: "Sink your hips back.")
        ],
        summary: "4 stretches · ~3 min · joints, spine"
    )

    static let all: [WorkoutSessionTemplate] = [
        coreBurner, wallSitLadder, squatHoldPulse, deskUnstiffener,
        pushUpLadder, legDay, fullBodyFlow, mobilityReset
    ]

    static func templates(for category: SessionCategory) -> [WorkoutSessionTemplate] {
        all.filter { $0.category == category }
    }

    /// The standard cooldown sequence run after any logged workout or session.
    static let cooldown = WorkoutSessionTemplate(
        name: "Cooldown",
        category: .stretches,
        moves: [
            SessionMove(name: "Neck rolls", kind: .flow, seconds: 30, weight: 1.0, cue: "Slow circles both ways."),
            SessionMove(name: "Hip flexor lunge", kind: .flow, seconds: 45, weight: 1.0, cue: "Tuck the pelvis under."),
            SessionMove(name: "Hamstring reach", kind: .flow, seconds: 30, weight: 1.0, cue: "Breathe. Don't bounce."),
            SessionMove(name: "Chest opener", kind: .flow, seconds: 30, weight: 1.0, cue: "Roll the shoulders back."),
            SessionMove(name: "Child's pose", kind: .flow, seconds: 60, weight: 1.0, cue: "Sink your hips back.")
        ],
        summary: "Four minutes. Still earns points."
    )
}
