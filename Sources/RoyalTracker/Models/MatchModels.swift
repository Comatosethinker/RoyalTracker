import Foundation

enum ElixirPhase: String, CaseIterable, Identifiable {
    case single = "1x"
    case double = "2x"
    case triple = "3x"

    var id: String { rawValue }

    var secondsPerElixir: TimeInterval {
        switch self {
        case .single: 2.8
        case .double: 1.4
        case .triple: 0.9
        }
    }

    var label: String {
        switch self {
        case .single: "单倍"
        case .double: "双倍"
        case .triple: "三倍"
        }
    }
}

struct PlayEvent: Identifiable, Hashable {
    let id = UUID()
    let card: BattleCard
    let elapsed: TimeInterval
    let phase: ElixirPhase
    let elixirAfterPlay: Double
}

struct CardCycleState {
    let available: [BattleCard]
    let cooling: [BattleCard]
    let unknownSlots: Int
}

enum WorkspaceMode: String, CaseIterable, Identifiable {
    case manual = "手动记牌"
    case vision = "屏幕识别"

    var id: String { rawValue }
}

struct CapturableWindow: Identifiable, Hashable {
    let id: UInt32
    let appName: String
    let title: String
    let width: Int
    let height: Int

    var displayName: String {
        title.isEmpty ? appName : "\(appName) - \(title)"
    }
}

struct DetectionFrame: Identifiable {
    let id = UUID()
    let timestamp: Date
    let matchElapsed: TimeInterval
    let movementScore: Double
    let image: Data?
}

enum DetectionLabelKind: String, CaseIterable, Identifiable, Codable {
    case unknown = "未标注"
    case cardPlay = "真实出牌"
    case falsePositive = "误报"
    case summonOrSpawn = "召唤/产物"
    case cloneEffect = "克隆效果"

    var id: String { rawValue }
}

struct DetectionAnnotation: Codable, Hashable {
    var kind: DetectionLabelKind = .unknown
    var cardID: String?
    var notes: String = ""
}
