import Foundation

struct WorkoutEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let exercise: Exercise
    let amount: Int
    let points: Int
    let date: Date

    init(id: UUID = UUID(), exercise: Exercise, amount: Int, date: Date = Date()) {
        self.id = id
        self.exercise = exercise
        self.amount = amount
        self.points = exercise.points(for: amount)
        self.date = date
    }
}
