import SwiftUI
import UserNotifications

struct HistoryView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var checklistViewModel: ChecklistViewModel
    @EnvironmentObject var vm: PlacesViewModel

    private let notificationService = NotificationService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    Button(action: simulateExitNotification) {
                        Text("Simulate Exit Notification")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .disabled(vm.places.isEmpty)

                    if vm.places.isEmpty {
                        Text("Add a place first to simulate an exit notification.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    }

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
        }
    }

    private func simulateExitNotification() {
        guard let place = vm.places.first else { return }

        let checklistTitles = checklistViewModel
        .enabledItems(for: place.id)
        .map { $0.title }

        let bodyText: String
        if checklistTitles.isEmpty {
            bodyText = "You left \(place.name). No enabled checklist items."
        } else {
            bodyText = "You left \(place.name). Don’t forget: " + checklistTitles.joined(separator: ", ")
        }

        notificationService.sendNotification(
            title: "Checklist Reminder",
            body: bodyText
        )

        historyStore.add(
            placeName: place.name,
            checklistName: "\(place.name) Checklist",
            checklistItems: checklistTitles,
            exitTime: Date()
        )
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