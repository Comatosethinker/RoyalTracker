import CoreImage
import CoreGraphics
import CoreVideo
import Foundation

final class MotionBurstDetector {
    private let context = CIContext()
    private var previousSample: [UInt8] = []
    private var lastEmit = Date.distantPast

    var sensitivity: Double = 0.18
    var cooldown: TimeInterval = 1.0

    func analyze(pixelBuffer: CVPixelBuffer) -> TrackerEvent? {
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        guard let sample = samplePixels(from: image) else { return nil }

        let score = motionScore(current: sample, previous: previousSample)
        previousSample = sample

        let now = Date()
        guard score >= sensitivity, now.timeIntervalSince(lastEmit) >= cooldown else {
            return nil
        }

        lastEmit = now
        return TrackerEvent(
            kind: .candidatePlay,
            confidence: min(1, score),
            message: "candidate motion burst"
        )
    }

    private func samplePixels(from image: CIImage) -> [UInt8]? {
        let width = 64
        let height = 36
        let bytesPerPixel = 4
        var pixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        guard let cgImage = context.createCGImage(image, from: image.extent) else { return nil }

        guard let bitmapContext = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * bytesPerPixel,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        bitmapContext.interpolationQuality = .low
        bitmapContext.draw(cgImage, in: bounds)
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
}
