import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @State private var showClearHistoryConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    if historyStore.events.isEmpty {
                        Spacer()

                        Text("No history yet")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(historyStore.events) { event in
                                    HistoryRowView(event: event)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !historyStore.events.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") {
                            showClearHistoryConfirmation = true
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .alert("Clear History?", isPresented: $showClearHistoryConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    historyStore.clear()
                }
            } message: {
                Text("This will remove all history events from the app.")
            }
        }
    }
}

struct HistoryRowView: View {
    let event: HistoryEvent

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: event.exitTime)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "clock")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.placeName)
                    .font(.headline)
                    .foregroundColor(.black)

                Text("Exited at \(formattedTime)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Triggered: \(event.checklistName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if !event.checklistItems.isEmpty {
                    Text("Items: " + event.checklistItems.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    HistoryView()
}
