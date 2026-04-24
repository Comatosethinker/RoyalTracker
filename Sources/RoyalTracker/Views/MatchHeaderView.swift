import SwiftUI

struct MatchHeaderView: View {
    @Bindable var store: MatchStore

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("对手圣水")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(MatchFormatters.elixir(store.currentElixir))
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 150, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text("时间")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(MatchFormatters.clock(store.elapsed))
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 120, alignment: .leading)

            Picker("阶段", selection: $store.selectedPhase) {
                ForEach(ElixirPhase.allCases) { phase in
                    Text(phase.label).tag(phase)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 210)

            Spacer()

            Button {
                store.toggleRunning()
            } label: {
                Label(store.isRunning ? "暂停" : "开始", systemImage: store.isRunning ? "pause.fill" : "play.fill")
            }
            .keyboardShortcut(.space, modifiers: [])

            Button {
                store.undoLastPlay()
            } label: {
                Label("撤销", systemImage: "arrow.uturn.backward")
            }
            .disabled(store.events.isEmpty)

            Button(role: .destructive) {
                store.resetMatch()
            } label: {
                Label("重开", systemImage: "arrow.counterclockwise")
            }
        }
    }
}
