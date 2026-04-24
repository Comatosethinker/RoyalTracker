import SwiftUI

struct VisionCaptureView: View {
    @Bindable var store: MatchStore
    @Bindable var captureStore: CaptureStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("屏幕识别")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button {
                    captureStore.refreshWindows()
                } label: {
                    Label("刷新窗口", systemImage: "arrow.clockwise")
                }
            }

            Picker("游戏窗口", selection: $captureStore.selectedWindowID) {
                Text("未选择").tag(UInt32?.none)
                ForEach(captureStore.windows) { window in
                    Text("\(window.displayName) · \(window.width)x\(window.height)")
                        .tag(Optional(window.id))
                }
            }

            HStack {
                Button {
                    if captureStore.isCapturing {
                        captureStore.stop()
                    } else {
                        captureStore.start { store.elapsed }
                    }
                } label: {
                    Label(captureStore.isCapturing ? "停止识别" : "开始识别", systemImage: captureStore.isCapturing ? "stop.fill" : "dot.viewfinder")
                }

                Button {
                    captureStore.clearFrames()
                } label: {
                    Label("清空事件", systemImage: "trash")
                }
                .disabled(captureStore.detectionFrames.isEmpty)

                Button {
                    captureStore.exportFrames()
                } label: {
                    Label("导出事件", systemImage: "square.and.arrow.down")
                }
                .disabled(captureStore.detectionFrames.isEmpty)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(captureStore.statusText)
                    .foregroundStyle(.secondary)

                HStack {
                    Text("灵敏度")
                        .frame(width: 58, alignment: .leading)
                    Slider(value: $captureStore.sensitivity, in: 0.05...0.45)
                    Text("\(Int(captureStore.sensitivity * 100))%")
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 42, alignment: .trailing)
                }

                HStack {
                    Text("帧率")
                        .frame(width: 58, alignment: .leading)
                    Slider(value: $captureStore.framesPerSecond, in: 3...15, step: 1)
                    Text("\(Int(captureStore.framesPerSecond)) fps")
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 58, alignment: .trailing)
                }
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))

            PreviewPanel(imageData: captureStore.previewImageData)

            Text("疑似出牌事件")
                .font(.title3.weight(.semibold))

            if captureStore.detectionFrames.isEmpty {
                Text("开始识别后，明显动画变化会出现在这里。第一版先保存事件帧，后续再接卡牌分类。")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            } else {
                Text("可导出为 PNG + labels.jsonl，用于后续人工标注和训练。")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(captureStore.detectionFrames) { frame in
                            DetectionFrameRow(frame: frame)
                        }
                    }
                }
            }
        }
        .padding(18)
        .onAppear {
            if captureStore.windows.isEmpty {
                captureStore.refreshWindows()
            }
        }
        .onDisappear {
            captureStore.stop()
        }
    }
}

private struct PreviewPanel: View {
    let imageData: Data?

    var body: some View {
        ZStack {
            if let imageData, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "rectangle.dashed")
                        .font(.largeTitle)
                    Text("等待窗口画面")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct DetectionFrameRow: View {
    let frame: DetectionFrame

    var body: some View {
        HStack(spacing: 12) {
            if let imageData = frame.image, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 118, height: 66)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.secondary.opacity(0.15))
                    .frame(width: 118, height: 66)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("疑似动画")
                    .font(.headline)
                Text("对局 \(MatchFormatters.clock(frame.matchElapsed)) · 变化 \(Int(frame.movementScore * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
