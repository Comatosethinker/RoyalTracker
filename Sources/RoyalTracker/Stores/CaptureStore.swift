import AppKit
import CoreImage
import CoreMedia
import Foundation
import Observation
import ScreenCaptureKit

@Observable
@MainActor
final class CaptureStore {
    var windows: [CapturableWindow] = []
    var selectedWindowID: UInt32?
    var isCapturing = false
    var detectionFrames: [DetectionFrame] = []
    var sensitivity: Double = 0.18
    var framesPerSecond: Double = 8
    var statusText = "选择游戏窗口后开始识别。"
    var previewImageData: Data?
    var lastExportURL: URL?
    var selectedFrameID: UUID?
    var annotations: [UUID: DetectionAnnotation] = [:]

    @ObservationIgnored private var stream: SCStream?
    @ObservationIgnored private var streamOutput: CaptureStreamOutput?
    @ObservationIgnored private var streamQueue = DispatchQueue(label: "RoyalTracker.capture.stream")
    @ObservationIgnored private var scWindows: [UInt32: SCWindow] = [:]
    @ObservationIgnored private var previousSample: [UInt8] = []
    @ObservationIgnored private var lastDetectionDate = Date.distantPast
    @ObservationIgnored private var matchElapsedProvider: (@MainActor () -> TimeInterval)?

    var selectedWindow: CapturableWindow? {
        windows.first { $0.id == selectedWindowID }
    }

    var selectedFrame: DetectionFrame? {
        detectionFrames.first { $0.id == selectedFrameID } ?? detectionFrames.first
    }

    func refreshWindows() {
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                let usableWindows = content.windows.filter { window in
                    window.frame.width >= 360 && window.frame.height >= 240
                }

                scWindows = Dictionary(uniqueKeysWithValues: usableWindows.map { ($0.windowID, $0) })
                windows = usableWindows.map { window in
                    CapturableWindow(
                        id: window.windowID,
                        appName: window.owningApplication?.applicationName ?? "Unknown",
                        title: window.title ?? "",
                        width: Int(window.frame.width),
                        height: Int(window.frame.height)
                    )
                }
                .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }

                if selectedWindowID == nil || scWindows[selectedWindowID ?? 0] == nil {
                    selectedWindowID = windows.first { window in
                        window.displayName.localizedCaseInsensitiveContains("Clash")
                            || window.displayName.localizedCaseInsensitiveContains("Royale")
                            || window.displayName.localizedCaseInsensitiveContains("皇室")
                    }?.id ?? windows.first?.id
                }

                statusText = windows.isEmpty ? "没有找到可采集窗口。" : "已找到 \(windows.count) 个窗口。"
            } catch {
                statusText = "无法读取窗口列表，请确认屏幕录制权限。"
            }
        }
    }

    func start(matchElapsed: @escaping @MainActor () -> TimeInterval) {
        guard !isCapturing else { return }
        guard selectedWindowID != nil else {
            statusText = "请先选择游戏窗口。"
            return
        }

        matchElapsedProvider = matchElapsed
        previousSample = []
        lastDetectionDate = .distantPast
        statusText = "正在启动屏幕采集。"

        Task {
            do {
                try await startStream()
                isCapturing = true
                statusText = "正在读取窗口画面。"
            } catch {
                isCapturing = false
                statusText = "启动失败，请检查屏幕录制权限或重新选择窗口。"
            }
        }
    }

    func stop() {
        let activeStream = stream
        stream = nil
        streamOutput = nil
        isCapturing = false
        statusText = "识别已暂停。"

        Task {
            try? await activeStream?.stopCapture()
        }
    }

    func clearFrames() {
        detectionFrames.removeAll()
        annotations.removeAll()
        selectedFrameID = nil
    }

    func annotation(for frame: DetectionFrame) -> DetectionAnnotation {
        annotations[frame.id] ?? DetectionAnnotation()
    }

    func updateAnnotation(for frame: DetectionFrame, _ annotation: DetectionAnnotation) {
        annotations[frame.id] = annotation
    }

    func exportFrames() {
        guard !detectionFrames.isEmpty else {
            statusText = "没有可导出的事件。"
            return
        }

        do {
            let exportURL = try makeExportFolder()
            var labelLines: [String] = []

            for (index, frame) in detectionFrames.reversed().enumerated() {
                let frameName = String(format: "event-%03d.png", index + 1)
                if let image = frame.image {
                    try image.write(to: exportURL.appendingPathComponent(frameName), options: .atomic)
                }

                let label = ExportedFrameLabel(
                    fileName: frameName,
                    timestamp: frame.timestamp,
                    matchElapsed: frame.matchElapsed,
                    movementScore: frame.movementScore,
                    annotation: annotation(for: frame)
                )
                let encoded = try JSONEncoder.royalTracker.encode(label)
                if let line = String(data: encoded, encoding: .utf8) {
                    labelLines.append(line)
                }
            }

            let labelText = labelLines.joined(separator: "\n").appending("\n")
            try labelText.write(to: exportURL.appendingPathComponent("labels.jsonl"), atomically: true, encoding: .utf8)

            lastExportURL = exportURL
            statusText = "已导出 \(detectionFrames.count) 个事件到 Captures。"
            NSWorkspace.shared.activateFileViewerSelecting([exportURL])
        } catch {
            statusText = "导出失败，请检查项目目录权限。"
        }
    }

    func handleFrame(_ image: CGImage) {
        let previewData = pngData(from: image)
        previewImageData = previewData

        guard let sample = samplePixels(from: image) else {
            statusText = "画面采样失败。"
            return
        }

        let movementScore = motionScore(current: sample, previous: previousSample)
        previousSample = sample

        let now = Date()
        guard movementScore >= sensitivity, now.timeIntervalSince(lastDetectionDate) >= 1.0 else {
            statusText = "监听中，画面变化 \(Int(movementScore * 100))%。"
            return
        }

        lastDetectionDate = now
        let frame = DetectionFrame(
            timestamp: now,
            matchElapsed: matchElapsedProvider?() ?? 0,
            movementScore: movementScore,
            image: previewData
        )
        detectionFrames.insert(frame, at: 0)
        detectionFrames = Array(detectionFrames.prefix(24))
        selectedFrameID = frame.id
        statusText = "检测到疑似出牌动画。"
    }

    private func startStream() async throws {
        if scWindows.isEmpty {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            scWindows = Dictionary(uniqueKeysWithValues: content.windows.map { ($0.windowID, $0) })
        }

        guard let selectedWindowID, let window = scWindows[selectedWindowID] else {
            throw CaptureError.windowNotFound
        }

        let filter = SCContentFilter(desktopIndependentWindow: window)
        let configuration = SCStreamConfiguration()
        configuration.capturesAudio = false
        configuration.queueDepth = 3
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(max(1, Int32(framesPerSecond))))
        configuration.width = max(640, Int(window.frame.width))
        configuration.height = max(360, Int(window.frame.height))

        let output = CaptureStreamOutput(store: self)
        let newStream = SCStream(filter: filter, configuration: configuration, delegate: nil)
        try newStream.addStreamOutput(output, type: .screen, sampleHandlerQueue: streamQueue)
        try await newStream.startCapture()

        streamOutput = output
        stream = newStream
    }

    private func samplePixels(from image: CGImage) -> [UInt8]? {
        let width = 64
        let height = 36
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.interpolationQuality = .low
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels
    }

    private func motionScore(current: [UInt8], previous: [UInt8]) -> Double {
        guard current.count == previous.count, !current.isEmpty else { return 0 }

        var changed = 0
        let pixelCount = current.count / 4
        for index in stride(from: 0, to: current.count, by: 4) {
            let red = abs(Int(current[index]) - Int(previous[index]))
            let green = abs(Int(current[index + 1]) - Int(previous[index + 1]))
            let blue = abs(Int(current[index + 2]) - Int(previous[index + 2]))
            if red + green + blue > 72 {
                changed += 1
            }
        }
        return Double(changed) / Double(pixelCount)
    }

    private func pngData(from image: CGImage) -> Data? {
        let bitmap = NSBitmapImageRep(cgImage: image)
        return bitmap.representation(using: .png, properties: [:])
    }
}

private enum CaptureError: Error {
    case windowNotFound
}

private struct ExportedFrameLabel: Codable {
    let schemaVersion = 1
    let fileName: String
    let timestamp: Date
    let matchElapsed: TimeInterval
    let movementScore: Double
    let labelKind: DetectionLabelKind
    let isCardPlay: Bool?
    let cardID: String?
    let notes: String

    init(
        fileName: String,
        timestamp: Date,
        matchElapsed: TimeInterval,
        movementScore: Double,
        annotation: DetectionAnnotation
    ) {
        self.fileName = fileName
        self.timestamp = timestamp
        self.matchElapsed = matchElapsed
        self.movementScore = movementScore
        self.labelKind = annotation.kind
        self.isCardPlay = annotation.kind == .unknown ? nil : annotation.kind == .cardPlay
        self.cardID = annotation.cardID
        self.notes = annotation.notes
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case fileName = "file_name"
        case timestamp
        case matchElapsed = "match_elapsed"
        case movementScore = "movement_score"
        case labelKind = "label_kind"
        case isCardPlay = "is_card_play"
        case cardID = "card_id"
        case notes
    }
}

private extension CaptureStore {
    func makeExportFolder() throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser
        let root = documents
            .appendingPathComponent("RoyalTracker", isDirectory: true)
            .appendingPathComponent("Captures", isDirectory: true)
        let stamp = ExportDateFormatter.shared.string(from: Date())
        let folder = root.appendingPathComponent("session-\(stamp)", isDirectory: true)

        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }
}

private enum ExportDateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}

private extension JSONEncoder {
    static var royalTracker: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}

private final class CaptureStreamOutput: NSObject, SCStreamOutput {
    private weak var store: CaptureStore?
    private let context = CIContext()

    init(store: CaptureStore) {
        self.store = store
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
        guard outputType == .screen, sampleBuffer.isValid else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        Task { @MainActor [weak store] in
            store?.handleFrame(cgImage)
        }
    }
}
