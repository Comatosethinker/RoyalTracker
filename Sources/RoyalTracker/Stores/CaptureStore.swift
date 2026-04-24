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
