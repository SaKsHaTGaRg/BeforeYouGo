//
//  NotificationService.swift
//  BeforeYouGo
//
//  Created by Artem Basko on 2026-03-14.
//

import Foundation
import UserNotifications
import Combine

@MainActor
final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            #if DEBUG
            if let error {
                print("[NotificationService] Permission error: \(error.localizedDescription)")
            } else {
                print("[NotificationService] Permission granted: \(granted)")
            }
            #endif
        }
    }

    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if soundEnabled {
            content.sound = .default
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
            if let error {
                print("[NotificationService] Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("[NotificationService] Notification scheduled successfully")
            }
            #endif
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        soundEnabled ? [.banner, .sound, .badge] : [.banner, .badge]
    }

    private var soundEnabled: Bool {
        UserDefaults.standard.object(forKey: "settings.soundEnabled") as? Bool ?? true
    }
}
