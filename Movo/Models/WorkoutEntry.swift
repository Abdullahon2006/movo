import Foundation

struct WorkoutEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let exercise: Exercise
    let amount: Double
    let points: Int
    let date: Date

    init(id: UUID = UUID(), exercise: Exercise, amount: Double, points: Int, date: Date = Date()) {
        self.id = id
        self.exercise = exercise
        self.amount = amount
        self.points = points
        self.date = date
    }
}

/// A completed timed session (holds/stretches/reps), logged distinctly from single quick-log entries.
struct SessionEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let templateName: String
    let points: Int
    let seconds: Int
    let date: Date

    init(id: UUID = UUID(), templateName: String, points: Int, seconds: Int, date: Date = Date()) {
        self.id = id
        self.templateName = templateName
        self.points = points
        self.seconds = seconds
        self.date = date
    }
}
