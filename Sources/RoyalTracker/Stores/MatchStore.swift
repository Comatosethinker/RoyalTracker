import Foundation
import Observation

@Observable
final class MatchStore {
    var workspaceMode: WorkspaceMode = .manual
    var selectedDeckIDs: Set<String> = []
    var events: [PlayEvent] = []
    var currentElixir: Double = 5
    var selectedPhase: ElixirPhase = .single
    var elapsed: TimeInterval = 0
    var isRunning = false
    var searchText = ""

    private var lastTick = Date()

    var selectedDeck: [BattleCard] {
        CardCatalog.cards.filter { selectedDeckIDs.contains($0.id) }
    }

    var observedCards: [BattleCard] {
        var seen: [String: BattleCard] = [:]
        for event in events {
            seen[event.card.id] = event.card
        }
        return seen.values.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var trackingPool: [BattleCard] {
        selectedDeck.isEmpty ? observedCards : selectedDeck
    }

    var cycleState: CardCycleState {
        let recentIDs = Array(events.reversed().map(\.card.id).uniqued().prefix(4))
        let cooling = recentIDs.compactMap { id in trackingPool.first(where: { $0.id == id }) }
        let available = trackingPool.filter { card in !recentIDs.contains(card.id) }
        let unknownSlots = max(0, 8 - trackingPool.count)
        return CardCycleState(available: available, cooling: cooling, unknownSlots: unknownSlots)
    }

    var filteredCards: [BattleCard] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return CardCatalog.cards
        }
        return CardCatalog.cards.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.category.localizedCaseInsensitiveContains(searchText)
                || $0.rarity.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    func tick() {
        let now = Date()
        let delta = now.timeIntervalSince(lastTick)
        lastTick = now

        guard isRunning else { return }
        elapsed += delta
        currentElixir = min(10, currentElixir + delta / selectedPhase.secondsPerElixir)
    }

    func toggleRunning() {
        lastTick = Date()
        isRunning.toggle()
    }

    func play(_ card: BattleCard) {
        tick()
        currentElixir = max(0, currentElixir - Double(card.elixir))
        events.append(PlayEvent(card: card, elapsed: elapsed, phase: selectedPhase, elixirAfterPlay: currentElixir))
    }

    func undoLastPlay() {
        guard let last = events.popLast() else { return }
        currentElixir = min(10, last.elixirAfterPlay + Double(last.card.elixir))
    }

    func resetMatch() {
        events.removeAll()
        currentElixir = 5
        elapsed = 0
        selectedPhase = .single
        isRunning = false
        lastTick = Date()
    }

    func toggleDeckCard(_ card: BattleCard) {
        if selectedDeckIDs.contains(card.id) {
            selectedDeckIDs.remove(card.id)
        } else if selectedDeckIDs.count < 8 {
            selectedDeckIDs.insert(card.id)
        }
    }

    func clearDeck() {
        selectedDeckIDs.removeAll()
    }
}

private extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
