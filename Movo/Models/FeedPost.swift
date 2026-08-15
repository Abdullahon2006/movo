import Foundation

enum FeedKind: String, Codable {
    case workout
    case session
    case challenge
    case liveSession
}

struct FeedPost: Codable, Identifiable, Equatable {
    let id: UUID
    var authorName: String
    var authorColorHex: String
    var stage: Stage
    var kind: FeedKind
    var detail: String
    var points: Int
    var date: Date
    var isMe: Bool
    var reactions: [String: Int]
    var commentCount: Int
    var hasPhoto: Bool

    init(
        id: UUID = UUID(),
        authorName: String,
        authorColorHex: String,
        stage: Stage,
        kind: FeedKind,
        detail: String,
        points: Int,
        date: Date = Date(),
        isMe: Bool = false,
        reactions: [String: Int] = [:],
        commentCount: Int = 0,
        hasPhoto: Bool = false
    ) {
        self.id = id
        self.authorName = authorName
        self.authorColorHex = authorColorHex
        self.stage = stage
        self.kind = kind
        self.detail = detail
        self.points = points
        self.date = date
        self.isMe = isMe
        self.reactions = reactions
        self.commentCount = commentCount
        self.hasPhoto = hasPhoto
    }

    var headline: String {
        switch kind {
        case .workout, .session: return "\(authorName) \(detail) · +\(points) pts"
        case .challenge: return detail
        case .liveSession: return "\(authorName) started a live session"
        }
    }

    var totalReactions: Int { reactions.values.reduce(0, +) }
}
