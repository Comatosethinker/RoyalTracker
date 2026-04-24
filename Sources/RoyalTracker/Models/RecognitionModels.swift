import Foundation

struct CardCandidate: Identifiable, Hashable {
    let id = UUID()
    let card: BattleCard
    let confidence: Double
    let reason: String
}

struct RecognitionEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let matchElapsed: TimeInterval
    let candidates: [CardCandidate]
    let shouldAskForConfirmation: Bool
}

protocol CardRecognitionEngine {
    func candidates(for frame: DetectionFrame, knownDeck: [BattleCard]) -> [CardCandidate]
}
