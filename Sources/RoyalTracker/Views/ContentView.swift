import SwiftUI

struct ContentView: View {
    @Bindable var store: MatchStore
    @Bindable var captureStore: CaptureStore
    @AppStorage("hasSeenVisionGuide") private var hasSeenVisionGuide = false
    @State private var showsVisionGuide = false

    var body: some View {
        NavigationSplitView {
            SidebarView(store: store)
        } detail: {
            VStack(spacing: 0) {
                MatchHeaderView(store: store)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)

                Divider()

                Picker("模式", selection: $store.workspaceMode) {
                    ForEach(WorkspaceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 18)
                .padding(.top, 10)

                HStack {
                    Text(modeHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        showsVisionGuide = true
                    } label: {
                        Label("使用说明", systemImage: "questionmark.circle")
                    }
                    .controlSize(.small)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 10)

                Divider()

                if store.workspaceMode == .manual {
                    HStack(spacing: 0) {
                        CardPickerView(store: store)
                            .frame(minWidth: 430)

                        Divider()

                        TrackingView(store: store)
                            .frame(minWidth: 420)
                    }
                } else {
                    HStack(spacing: 0) {
                        VisionCaptureView(store: store, captureStore: captureStore)
                            .frame(minWidth: 520)

                        Divider()

                        TrackingView(store: store)
                            .frame(minWidth: 420)
                    }
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { _ in
            store.tick()
        }
        .onAppear {
            if !hasSeenVisionGuide {
                showsVisionGuide = true
                hasSeenVisionGuide = true
            }
        }
        .sheet(isPresented: $showsVisionGuide) {
            VisionGuideView(store: store, isPresented: $showsVisionGuide)
                .frame(width: 640, height: 560)
        }
    }

    private var modeHint: String {
        switch store.workspaceMode {
        case .manual:
            "手动记牌适合先熟悉圣水和卡组循环逻辑。切到屏幕识别后可以采集训练样本。"
        case .vision:
            "屏幕识别会读取你选择的窗口，检测疑似出牌动画，并支持导出标注样本。"
        }
    }
}
