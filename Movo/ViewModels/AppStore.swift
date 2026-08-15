import Foundation
import Combine
import SwiftUI

struct LevelUpEvent: Identifiable, Equatable {
    let id = UUID()
    let stage: Stage
    let unlockedItems: [String]
}

struct MovoDrop: Equatable {
    var exercise: Exercise
    var amount: Double
    var expiresAt: Date
}

struct WorkoutPrefill: Identifiable {
    let id = UUID()
    var exercise: Exercise
    var amount: Double
}

@MainActor
final class AppStore: ObservableObject {
    @Published var character: CharacterProfile { didSet { persist() } }
    @Published var onboarding: OnboardingState { didSet { persist() } }
    @Published var settings: AppSettings { didSet { persist() } }
    @Published var workoutLog: [WorkoutEntry] { didSet { persist() } }
    @Published var sessionLog: [SessionEntry] { didSet { persist() } }
    @Published var feed: [FeedPost] { didSet { persist() } }

    /// Non-persistent, in-memory session/demo state.
    @Published var levelUpEvent: LevelUpEvent?
    @Published var workoutInProgress: Bool = false
    @Published var dialogueSeed: Int = 0
    @Published var crewOnlineCount: Int = 9
    @Published var activeDrop: MovoDrop?
    @Published var liveSessionMember: CrewMember? = .idris
    @Published var workoutSheetPrefill: WorkoutPrefill?
    @Published var isSessionFlowPresented: Bool = false

    var hasCreatedCharacter: Bool { !character.name.isEmpty }
    var hasCompletedOnboarding: Bool { onboarding.isComplete }

    private let defaults = UserDefaults.standard
    private let characterKey = "movo.character.v2"
    private let onboardingKey = "movo.onboarding.v2"
    private let settingsKey = "movo.settings.v2"
    private let workoutLogKey = "movo.workoutLog.v2"
    private let sessionLogKey = "movo.sessionLog.v2"
    private let feedKey = "movo.feed.v2"

    private var crewTimer: Timer?

    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        func load<T: Decodable>(_ key: String, _ type: T.Type) -> T? {
            guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
            return try? decoder.decode(T.self, from: data)
        }

        character = load(characterKey, CharacterProfile.self) ?? .empty
        onboarding = load(onboardingKey, OnboardingState.self) ?? OnboardingState()
        settings = load(settingsKey, AppSettings.self) ?? AppSettings()
        workoutLog = load(workoutLogKey, [WorkoutEntry].self) ?? []
        sessionLog = load(sessionLogKey, [SessionEntry].self) ?? []
        feed = load(feedKey, [FeedPost].self) ?? AppStore.seedFeed
    }

    // MARK: - Onboarding & creation

    func completeOnboarding() {
        character.totalPoints = onboarding.resolvedStartPoints
        character.multiplier = onboarding.resolvedMultiplier
        character.weeklyTarget = max(1, onboarding.sessionsPerWeek)
        onboarding.isComplete = true
    }

    func createCharacter(name: String, accent: AccentOption) {
        character.name = name
        character.accent = accent
        settings.accent = accent
    }

    /// Accent is a single value shared by the app chrome and the Movo's body — one pick re-skins both.
    func updateAccent(_ accent: AccentOption) {
        settings.accent = accent
        character.accent = accent
    }

    // MARK: - Derived activity state

    private var activityDates: [Date] {
        workoutLog.map(\.date) + sessionLog.map(\.date)
    }

    var currentStreakDays: Int {
        let cal = Calendar.current
        let days = Set(activityDates.map { cal.startOfDay(for: $0) })
        guard !days.isEmpty else { return 0 }
        var streak = 0
        var cursor = cal.startOfDay(for: Date())
        if !days.contains(cursor) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = yesterday
        }
        while days.contains(cursor) {
            streak += 1
            guard let prior = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prior
        }
        return streak
    }

    var idleDays: Int {
        let cal = Calendar.current
        guard let last = activityDates.max() else { return 999 }
        return max(0, cal.dateComponents([.day], from: cal.startOfDay(for: last), to: cal.startOfDay(for: Date())).day ?? 0)
    }

    var hoursSinceLastWorkout: Double? {
        guard let last = activityDates.max() else { return nil }
        return Date().timeIntervalSince(last) / 3600.0
    }

    var weeklySessionsCount: Int {
        let cal = Calendar.current
        guard let weekAgo = cal.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        let days = Set(activityDates.filter { $0 >= weekAgo }.map { cal.startOfDay(for: $0) })
        return days.count
    }

    var weeklyTargetMet: Bool { weeklySessionsCount >= character.weeklyTarget }

    var mood: Mood {
        Mood.resolve(
            workoutInProgress: workoutInProgress,
            hoursSinceLastWorkout: hoursSinceLastWorkout,
            idleDays: idleDays,
            weeklyTargetMet: weeklyTargetMet
        )
    }

    var currentDialogue: String { mood.line(seed: dialogueSeed) }

    var crewRank: Int {
        1 + CrewMember.roster.filter { $0.points > character.totalPoints }.count
    }

    // MARK: - Scoring

    func streakBonus() -> Double { 1.0 + Double(min(currentStreakDays, 10)) * 0.02 }

    func pointsForExercise(_ exercise: Exercise, amount: Double) -> Int {
        guard amount > 0 else { return 0 }
        let total = exercise.basePoints(for: amount) * streakBonus() * character.multiplier
        return max(0, Int(total.rounded()))
    }

    func pointsForSession(_ template: WorkoutSessionTemplate) -> Int {
        let base = template.moves.reduce(0.0) { $0 + (Double($1.seconds) / 10.0) * $1.weight }
        return max(0, Int((base * streakBonus() * character.multiplier).rounded()))
    }

    // MARK: - Logging

    @discardableResult
    func logWorkout(exercise: Exercise, amount: Double, postToFeed: Bool) -> Int {
        guard amount > 0 else { return 0 }
        let pts = pointsForExercise(exercise, amount: amount)
        workoutLog.insert(WorkoutEntry(exercise: exercise, amount: amount, points: pts), at: 0)
        applyPoints(pts)
        dialogueSeed += 1
        if postToFeed {
            insertMyFeedPost(kind: .workout, detail: "logged \(amount.trimmedString) \(exercise.displayName.lowercased())", points: pts)
        }
        return pts
    }

    @discardableResult
    func logSession(_ template: WorkoutSessionTemplate, postToFeed: Bool) -> Int {
        let pts = pointsForSession(template)
        sessionLog.insert(SessionEntry(templateName: template.name, points: pts, seconds: template.totalSeconds), at: 0)
        applyPoints(pts)
        dialogueSeed += 1
        if postToFeed {
            insertMyFeedPost(kind: .session, detail: "finished \(template.name)", points: pts)
        }
        return pts
    }

    func insertMyFeedPost(kind: FeedKind, detail: String, points: Int) {
        feed.insert(FeedPost(
            authorName: character.name.isEmpty ? "You" : character.name,
            authorColorHex: character.accent.color.toHex(),
            stage: character.stage,
            kind: kind,
            detail: detail,
            points: points,
            isMe: true,
            reactions: [:],
            commentCount: 0,
            hasPhoto: false
        ), at: 0)
    }

    private func applyPoints(_ pts: Int) {
        let oldStage = character.stage
        character.totalPoints = max(0, character.totalPoints + pts)
        let newStage = character.stage
        if newStage.rawValue > oldStage.rawValue {
            levelUpEvent = LevelUpEvent(stage: newStage, unlockedItems: newStage.levelUpRewards)
        }
    }

    // MARK: - Recovery quick actions (sulking state)

    func logQuickRecovery(exercise: Exercise, amount: Double) {
        logWorkout(exercise: exercise, amount: amount, postToFeed: false)
    }

    // MARK: - Cosmetics

    func purchase(_ item: CosmeticItem) {
        guard character.unlockState(for: item) == .purchasable, character.totalPoints >= item.costPts else { return }
        character.totalPoints -= item.costPts
        character.ownedItemIDs.insert(item.id)
    }

    func equip(_ item: CosmeticItem) {
        guard character.isOwned(item) else { return }
        character.equippedBySlot[item.slot.rawValue] = item.id
    }

    // MARK: - Feed interactions

    func react(to postID: UUID, emoji: String) {
        guard let idx = feed.firstIndex(where: { $0.id == postID }) else { return }
        feed[idx].reactions[emoji, default: 0] += 1
    }

    // MARK: - Navigation helpers

    func presentWorkoutLog(exercise: Exercise = .pushUps, amount: Double? = nil) {
        workoutSheetPrefill = WorkoutPrefill(exercise: exercise, amount: amount ?? exercise.defaultAmount)
    }

    func acceptDrop() {
        guard let drop = activeDrop else { return }
        presentWorkoutLog(exercise: drop.exercise, amount: drop.amount)
    }

    // MARK: - Simulated crew activity

    func startSimulatedCrewActivity() {
        if activeDrop == nil {
            activeDrop = MovoDrop(exercise: .jumpingJacks, amount: 10, expiresAt: Date().addingTimeInterval(120))
        }
        guard crewTimer == nil else { return }
        crewTimer = Timer.scheduledTimer(withTimeInterval: 9, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickCrewActivity() }
        }
    }

    func stopSimulatedCrewActivity() {
        crewTimer?.invalidate()
        crewTimer = nil
    }

    private func tickCrewActivity() {
        crewOnlineCount = max(3, min(24, crewOnlineCount + Int.random(in: -1...2)))

        if let drop = activeDrop, drop.expiresAt < Date() {
            activeDrop = MovoDrop(
                exercise: Exercise.allCases.randomElement() ?? .jumpingJacks,
                amount: 10,
                expiresAt: Date().addingTimeInterval(120)
            )
        }

        guard Bool.random() else { return }
        let member = CrewMember.roster.randomElement() ?? .yara
        let exercise = Exercise.allCases.randomElement() ?? .squats
        let amount = exercise.defaultAmount
        let pts = Int(exercise.basePoints(for: amount).rounded())
        let detail = exercise.kind == .dist
            ? "ran \(amount.trimmedString) km"
            : "logged \(Int(amount)) \(exercise.displayName.lowercased())"

        feed.insert(FeedPost(
            authorName: member.name,
            authorColorHex: member.colorHex,
            stage: member.stage,
            kind: .workout,
            detail: detail,
            points: pts,
            reactions: ["🔥": Int.random(in: 1...20)],
            commentCount: Int.random(in: 0...8),
            hasPhoto: Bool.random()
        ), at: 0)

        if feed.count > 40 { feed.removeLast(feed.count - 40) }
    }

    // MARK: - Persistence

    private func persist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        func save<T: Encodable>(_ value: T, _ key: String) {
            if let data = try? encoder.encode(value) { defaults.set(data, forKey: key) }
        }

        save(character, characterKey)
        save(onboarding, onboardingKey)
        save(settings, settingsKey)
        save(workoutLog, workoutLogKey)
        save(sessionLog, sessionLogKey)
        save(feed, feedKey)
    }

    private static var seedFeed: [FeedPost] {
        [
            FeedPost(authorName: "Yara", authorColorHex: "#57B4FF", stage: .rookie, kind: .workout, detail: "logged 30 squats", points: 45, date: Date().addingTimeInterval(-240), reactions: ["🔥": 14, "💪": 8, "🤩": 3], commentCount: 6, hasPhoto: true),
            FeedPost(authorName: "Sam", authorColorHex: "#FF7FC4", stage: .athlete, kind: .workout, detail: "ran 3.2 km", points: 128, date: Date().addingTimeInterval(-1320), reactions: ["🔥": 1], commentCount: 0),
            FeedPost(authorName: "Idris", authorColorHex: "#C6F24E", stage: .rookie, kind: .liveSession, detail: "started a live session", points: 0, date: Date().addingTimeInterval(-1800))
        ]
    }
}
