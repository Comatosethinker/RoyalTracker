import SwiftUI

struct ContentView: View {
    @State private var events: [TrackerEvent] = []
    private let store = SharedEventStore()
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start from Control Center")
                            .font(.headline)
                        Text("Long-press Screen Recording, choose RoyalTracker Broadcast, then start the broadcast.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Events") {
                    if events.isEmpty {
                        Text("No broadcast events yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(events.reversed()) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.message)
                                    .font(.headline)
                                Text("\(event.kind.rawValue) · confidence \(Int(event.confidence * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("RoyalTracker")
            .toolbar {
                Button("Clear") {
                    store.clear()
                    events = []
                }
            }
            .onAppear {
                events = store.readEvents()
            }
            .onReceive(timer) { _ in
                events = store.readEvents()
            }
        }
    }
}
