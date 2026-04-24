import CoreMedia
import ReplayKit

final class SampleHandler: RPBroadcastSampleHandler {
    private let eventStore = SharedEventStore()
    private let detector = MotionBurstDetector()

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        eventStore.append(TrackerEvent(kind: .status, confidence: 1, message: "broadcast started"))
    }

    override func broadcastPaused() {
        eventStore.append(TrackerEvent(kind: .status, confidence: 1, message: "broadcast paused"))
    }

    override func broadcastResumed() {
        eventStore.append(TrackerEvent(kind: .status, confidence: 1, message: "broadcast resumed"))
    }

    override func broadcastFinished() {
        eventStore.append(TrackerEvent(kind: .status, confidence: 1, message: "broadcast finished"))
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if let event = detector.analyze(pixelBuffer: pixelBuffer) {
            eventStore.append(event)
        }
    }
}
