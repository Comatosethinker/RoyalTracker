import Foundation

final class SharedEventStore {
    private let fileName = "events.jsonl"
    private let maxEvents = 200

    private var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.value)?
            .appendingPathComponent(fileName)
    }

    func append(_ event: TrackerEvent) {
        guard let fileURL else { return }
        guard let data = try? JSONEncoder.royalTracker.encode(event) else { return }

        var line = data
        line.append(0x0A)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                defer { try? handle.close() }
                try? handle.seekToEnd()
                try? handle.write(contentsOf: line)
            }
        } else {
            try? line.write(to: fileURL, options: .atomic)
        }

        trimIfNeeded()
    }

    func readEvents() -> [TrackerEvent] {
        guard let fileURL else { return [] }
        guard let text = try? String(contentsOf: fileURL, encoding: .utf8) else { return [] }

        return text
            .split(separator: "\n")
            .suffix(maxEvents)
            .compactMap { line in
                guard let data = line.data(using: .utf8) else { return nil }
                return try? JSONDecoder.royalTracker.decode(TrackerEvent.self, from: data)
            }
    }

    func clear() {
        guard let fileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func trimIfNeeded() {
        let events = readEvents()
        guard events.count > maxEvents, let fileURL else { return }

        let trimmed = events.suffix(maxEvents)
        let lines = trimmed.compactMap { event -> String? in
            guard let data = try? JSONEncoder.royalTracker.encode(event) else { return nil }
            return String(data: data, encoding: .utf8)
        }
        try? lines.joined(separator: "\n").appending("\n").write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

private extension JSONEncoder {
    static var royalTracker: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var royalTracker: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
