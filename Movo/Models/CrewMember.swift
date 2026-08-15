import Foundation

/// Simulated crew roster used to make the feed, live sessions and crew rank feel populated
/// without any real backend — a hackathon-friendly stand-in for social infrastructure.
struct CrewMember: Identifiable, Codable, Equatable {
    var id: String { name }
    var name: String
    var colorHex: String
    var stage: Stage
    var points: Int

    static let yara = CrewMember(name: "Yara", colorHex: "#57B4FF", stage: .rookie, points: 520)
    static let sam = CrewMember(name: "Sam", colorHex: "#FF7FC4", stage: .athlete, points: 1280)
    static let idris = CrewMember(name: "Idris", colorHex: "#C6F24E", stage: .rookie, points: 610)
    static let nova = CrewMember(name: "Nova", colorHex: "#FFB13D", stage: .athlete, points: 980)
    static let ricochet = CrewMember(name: "Ricochet", colorHex: "#57B4FF", stage: .hatchling, points: 240)

    static let roster: [CrewMember] = [yara, sam, idris, nova, ricochet]
}
