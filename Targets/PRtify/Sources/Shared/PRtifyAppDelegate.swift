//
//  PRtifyAppDelegate.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/01.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation
import UserNotifications

@MainActor
class PRtifyAppDelegate: NSObject, ObservableObject, Loggable {
    let session = Session.shared

    override init() {
        super.init()
    }
}

extension PRtifyAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .sound, .list, .banner]
    }
}
