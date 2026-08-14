import Foundation

struct FeedPost: Codable, Identifiable, Equatable {
    let id: UUID
    let characterName: String
    let exercise: Exercise
    let amount: Int
    let points: Int
    let date: Date

    init(id: UUID = UUID(), characterName: String, exercise: Exercise, amount: Int, points: Int, date: Date = Date()) {
        self.id = id
        self.characterName = characterName
        self.exercise = exercise
        self.amount = amount
        self.points = points
        self.date = date
    }

    var headline: String {
        "\(characterName) logged \(amount) \(exercise.displayName.lowercased()) +\(points) pts"
    }
}
