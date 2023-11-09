//
//  PRtifyAppDelegate.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/01.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftData
import Logging
import PulseLogHandler

@MainActor
class PRtifyAppDelegate: NSObject, ObservableObject {
    let session = Session.shared
    
    let container: ModelContainer = {
        let schema = Schema([Node.self])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Unresolved error \(error), \(error.localizedDescription)")
        }
    }()
    
    override init() {
        super.init()
        
        LoggingSystem.bootstrap(PersistentLogHandler.init)
        
        Task {
            await session.backgroundTaskSchedular.mainContext = container.mainContext
        }
    }
}

extension PRtifyAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .sound, .list, .banner]
    }
}
