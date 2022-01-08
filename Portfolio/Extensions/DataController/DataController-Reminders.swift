//
//  DataController-Reminders.swift
//  Portfolio
//
//  Created by MacBook Pro on 02/01/2022.
//

import UserNotifications

extension DataController {
    /// Used to add reminder. If there is no permission then it requests it.
    /// - Parameters:
    ///   - project: Project
    ///   - completion: Completion Handler
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotifications { success in
                    if success {
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: project, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    /// Used to remove all pending request for the project
    /// - Parameter project: Project
    func removeReminders(for project: Project) {
        let center = UNUserNotificationCenter.current()
        let id = project.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Used to request permission to use notification center
    /// - Parameter completion: completion handler
    private func requestNotifications(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }

    }

    /// Used to create and place request in the notification center
    /// - Parameters:
    ///   - project: Project
    ///   - completion: completion handler
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        // setting up the notification content
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = project.projectTitle

        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }

        // configuring notification trigger
        let components = Calendar.current.dateComponents([.hour, .minute], from: project.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // wrapping content and trigger into single notification
        let id = project.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        // sending request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
