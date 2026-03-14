import SwiftUI
import UserNotifications

struct HistoryView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var checklistViewModel: ChecklistViewModel

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
        let placeName = "Home"

        let checklistTitles = checklistViewModel.items
            .filter { $0.isEnabled }
            .map { $0.title }

        let bodyText: String
        if checklistTitles.isEmpty {
            bodyText = "You left \(placeName). No enabled checklist items."
        } else {
            bodyText = "You left \(placeName). Don’t forget: " + checklistTitles.joined(separator: ", ")
        }

        notificationService.sendNotification(
            title: "Checklist Reminder",
            body: bodyText
        )

        historyStore.add(
            placeName: placeName,
            checklistName: "\(placeName) Checklist",
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
        .environmentObject(HistoryStore())
        .environmentObject(ChecklistViewModel())
}
