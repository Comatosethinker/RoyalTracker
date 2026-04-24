import SwiftUI

struct CardPickerView: View {
    @Bindable var store: MatchStore

    private let columns = [
        GridItem(.adaptive(minimum: 118, maximum: 160), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("对方出牌")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button {
                    store.clearDeck()
                } label: {
                    Label("清空卡组", systemImage: "xmark.circle")
                }
                .disabled(store.selectedDeckIDs.isEmpty)
            }

            TextField("搜索卡牌、类型或稀有度", text: $store.searchText)
                .textFieldStyle(.roundedBorder)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(store.filteredCards) { card in
                        CardButton(card: card, isInDeck: store.selectedDeckIDs.contains(card.id)) {
                            store.play(card)
                        } deckAction: {
                            store.toggleDeckCard(card)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(18)
    }
}

private struct CardButton: View {
    let card: BattleCard
    let isInDeck: Bool
    let playAction: () -> Void
    let deckAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("\(card.elixir)")
                    .font(.headline.monospacedDigit())
                    .frame(width: 28, height: 28)
                    .background(.blue.opacity(0.18), in: Circle())
                Spacer()
                Button {
                    deckAction()
                } label: {
                    Image(systemName: isInDeck ? "star.fill" : "star")
                }
                .buttonStyle(.borderless)
                .help(isInDeck ? "从对手卡组移除" : "加入对手卡组")
            }

            Text(card.name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text("\(card.rarity.rawValue) · \(card.category)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Button {
                playAction()
            } label: {
                Label("记录出牌", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.small)
        }
        .padding(10)
        .frame(minHeight: 126)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isInDeck ? .blue.opacity(0.65) : .secondary.opacity(0.18), lineWidth: isInDeck ? 2 : 1)
        }
    }
}
