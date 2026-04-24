import Foundation

enum MatchFormatters {
    static func clock(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    static func elixir(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
}
