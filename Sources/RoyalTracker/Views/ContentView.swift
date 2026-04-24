import SwiftUI

struct ContentView: View {
    @Bindable var store: MatchStore
    @Bindable var captureStore: CaptureStore

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
                .padding(.vertical, 10)

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
    }
}
