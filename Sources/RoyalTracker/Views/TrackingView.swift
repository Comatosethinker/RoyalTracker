import SwiftUI

struct TrackingView: View {
    @Bindable var store: MatchStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                CyclePanel(title: "可能在手", cards: store.cycleState.available, emptyText: "先记录对方出牌，或用星标锁定对手 8 张卡组。")

                CyclePanel(title: "暂不可用", cards: store.cycleState.cooling, emptyText: "最近 4 张会显示在这里。")

                if store.cycleState.unknownSlots > 0 {
                    Label("未知卡位 \(store.cycleState.unknownSlots) 张", systemImage: "questionmark.circle")
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("出牌记录")
                        .font(.title3.weight(.semibold))

                    if store.events.isEmpty {
                        Text("开始后点击左侧卡牌记录对方出牌。圣水会按当前阶段自动恢复。")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.events.reversed()) { event in
                            HStack {
                                Text(MatchFormatters.clock(event.elapsed))
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 58, alignment: .leading)
                                Text(event.card.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("-\(event.card.elixir)")
                                    .font(.system(.body, design: .monospaced))
                                Text("余 \(MatchFormatters.elixir(event.elixirAfterPlay))")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 72, alignment: .trailing)
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
            }
            .padding(18)
        }
    }
}

private struct CyclePanel: View {
    let title: String
    let cards: [BattleCard]
    let emptyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.weight(.semibold))

            if cards.isEmpty {
                Text(emptyText)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 116), spacing: 8)], spacing: 8) {
                    ForEach(cards) { card in
                        HStack(spacing: 8) {
                            Text("\(card.elixir)")
                                .font(.callout.monospacedDigit().weight(.semibold))
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            Text(card.name)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}
