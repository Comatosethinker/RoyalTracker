import Foundation

struct TrackerEvent: Codable, Identifiable, Hashable {
    enum Kind: String, Codable {
        case candidatePlay
        case recognizedCard
        case status
    }

    let id: UUID
    let kind: Kind
    let timestamp: Date
    let elapsedSeconds: TimeInterval?
    let cardID: String?
    let confidence: Double
    let message: String

    init(
        id: UUID = UUID(),
        kind: Kind,
        timestamp: Date = Date(),
        elapsedSeconds: TimeInterval? = nil,
        cardID: String? = nil,
        confidence: Double,
        message: String
    ) {
        self.id = id
        self.kind = kind
        self.timestamp = timestamp
        self.elapsedSeconds = elapsedSeconds
        self.cardID = cardID
        self.confidence = confidence
        self.message = message
    }
}
