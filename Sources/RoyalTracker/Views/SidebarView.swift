import SwiftUI

struct SidebarView: View {
    @Bindable var store: MatchStore

    var body: some View {
        List {
            Section("对局") {
                Label("手动记牌", systemImage: "rectangle.grid.2x2")
                Label("圣水估算", systemImage: "drop.fill")
                Label("循环判断", systemImage: "arrow.triangle.2.circlepath")
            }

            Section("对手卡组") {
                ForEach(store.selectedDeck) { card in
                    Label {
                        Text("\(card.name) · \(card.elixir)")
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }

                if store.selectedDeck.isEmpty {
                    Text("未锁定卡组时，将按已出现卡牌推断。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("RoyalTracker")
    }
}
