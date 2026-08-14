import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    @Published var character: CharacterProfile {
        didSet { persist() }
    }
    @Published var workoutLog: [WorkoutEntry] {
        didSet { persist() }
    }
    @Published var feed: [FeedPost] {
        didSet { persist() }
    }

    var hasCreatedCharacter: Bool { !character.name.isEmpty }

    private let defaults = UserDefaults.standard
    private let characterKey = "movo.character"
    private let workoutLogKey = "movo.workoutLog"
    private let feedKey = "movo.feed"

    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let data = UserDefaults.standard.data(forKey: "movo.character"),
           let saved = try? decoder.decode(CharacterProfile.self, from: data) {
            character = saved
        } else {
            character = .empty
        }

        if let data = UserDefaults.standard.data(forKey: "movo.workoutLog"),
           let saved = try? decoder.decode([WorkoutEntry].self, from: data) {
            workoutLog = saved
        } else {
            workoutLog = []
        }

        if let data = UserDefaults.standard.data(forKey: "movo.feed"),
           let saved = try? decoder.decode([FeedPost].self, from: data) {
            feed = saved
        } else {
            feed = AppStore.seedFeed
        }
    }

    func createCharacter(name: String, bodyColorHex: String, outfitColorHex: String) {
        character = CharacterProfile(name: name, bodyColorHex: bodyColorHex, outfitColorHex: outfitColorHex, totalPoints: 0)
    }

    func logWorkout(exercise: Exercise, amount: Int) {
        guard amount > 0 else { return }
        let entry = WorkoutEntry(exercise: exercise, amount: amount)
        workoutLog.insert(entry, at: 0)
        character.totalPoints += entry.points

        let post = FeedPost(
            characterName: character.name.isEmpty ? "You" : character.name,
            exercise: exercise,
            amount: amount,
            points: entry.points
        )
        feed.insert(post, at: 0)
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let data = try? encoder.encode(character) {
            defaults.set(data, forKey: characterKey)
        }
        if let data = try? encoder.encode(workoutLog) {
            defaults.set(data, forKey: workoutLogKey)
        }
        if let data = try? encoder.encode(feed) {
            defaults.set(data, forKey: feedKey)
        }
    }

    private static var seedFeed: [FeedPost] {
        [
            FeedPost(characterName: "Blaze", exercise: .pushUps, amount: 20, points: 40, date: Date().addingTimeInterval(-3600)),
            FeedPost(characterName: "Nova", exercise: .running, amount: 15, points: 75, date: Date().addingTimeInterval(-7200)),
            FeedPost(characterName: "Ricochet", exercise: .squats, amount: 30, points: 60, date: Date().addingTimeInterval(-10800))
        ]
    }
}
