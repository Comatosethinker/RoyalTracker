import SwiftUI

struct VisionGuideView: View {
    @Bindable var store: MatchStore
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("RoyalTracker 屏幕识别版")
                        .font(.largeTitle.weight(.semibold))
                    Text("Mac 版目前定位是开发、采集和标注工具。它不会读取游戏内存，也不会自动操作游戏。")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
                .help("关闭")
            }

            Divider()

            VStack(alignment: .leading, spacing: 14) {
                GuideStep(number: 1, title: "准备画面", detail: "在 Mac 上打开游戏窗口、模拟器，或把手机投屏到 Mac。第一版更适合采集样本，不适合作为最终玩家端。")
                GuideStep(number: 2, title: "切到屏幕识别", detail: "在主界面选择“屏幕识别”，点击“刷新窗口”，选择 Clash Royale 或投屏窗口。")
                GuideStep(number: 3, title: "授权屏幕录制", detail: "如果 macOS 提示权限，请到系统设置允许 RoyalTracker 录制屏幕。授权后可能需要重启 App。")
                GuideStep(number: 4, title: "开始识别和标注", detail: "点击“开始识别”。检测到疑似出牌动画后，选择事件，标注为真实出牌、误报、召唤/产物或克隆效果。")
                GuideStep(number: 5, title: "导出训练样本", detail: "点击“导出事件”。样本会保存到 ~/Documents/RoyalTracker/Captures/，包含 PNG 截图和 labels.jsonl。")
            }

            Spacer()

            HStack {
                Label("后续训练版会读取这些导出样本，训练出的模型再更新回 Mac 和 iOS 版。", systemImage: "brain")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("进入手动记牌") {
                    store.workspaceMode = .manual
                    isPresented = false
                }
                Button("进入屏幕识别") {
                    store.workspaceMode = .vision
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(26)
    }
}

private struct GuideStep: View {
    let number: Int
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.blue, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
