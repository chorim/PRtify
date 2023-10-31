//
//  BackgroundTaskScheduler.swift
//  PRtify
//
//  Created by Insu Byeon on 10/24/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import BackgroundTasks
import UserNotifications

public class BackgroundTaskScheduler: Loggable {
    private unowned let session: Session
    
    private var backgroundTimer: DispatchSourceTimer? {
        willSet {
            guard backgroundTimer !== newValue else { return }

            backgroundTimer?.cancel()
        }
        didSet {
            guard backgroundTimer !== oldValue else { return }

            backgroundTimer?.activate()
        }
    }
    
    init(session: Session) {
        self.session = session
    }
    
    public static let backgroundRefreshBackgroundTaskIdentifier: String =
        "\(Bundle.prtify.bundleIdentifier!).background-refresh"
    public static let dataCleansingBackgroundTaskIdentifier: String =
        "\(Bundle.prtify.bundleIdentifier!).data-cleansing"
    
    static var preferredBackgroundTasksTimeInterval: TimeInterval {
        #if DEBUG
        60 // Fetch no earlier than 1 minute from now
        #else
        (16 / 2) * 60 // Fetch no earlier than 8 minutes from now
        #endif
    }
    
    static var preferredBackgroundRefreshDate: Date {
        Date(timeIntervalSinceNow: preferredBackgroundTasksTimeInterval)
    }
    
    func newBackgroundTimer(by username: String) -> DispatchSourceTimer {
        let timerSource = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        timerSource.setEventHandler {
            Task {
                do {
                    let nodes = try await self.session.fetchPullRequests(by: username)
                    #if DEBUG
                    let content = UNMutableNotificationContent()
                    content.title = "[DEV] New pull request from background task!"
                    content.subtitle = "Check it now!"
                    let request = UNNotificationRequest(
                        identifier: UUID().uuidString,
                        content: content,
                        trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    )
                    try await UNUserNotificationCenter.current().add(request)
                    #endif
                    self.logger.info("Nodes: \(String(describing: nodes))")
                } catch {
                    self.logger.error("Error retrieving data from background scheduler: \(error.localizedDescription)")
                }
            }
        }
        timerSource.schedule(
            deadline: .now() + Self.preferredBackgroundTasksTimeInterval,
            repeating: Self.preferredBackgroundTasksTimeInterval,
            leeway: .seconds(30)
        )
        logger.notice("New background timer has been created")
        return timerSource
    }
    
    func invalidate() {
        backgroundTimer = nil
        BGTaskScheduler.shared.cancelAllTaskRequests()
        logger.notice("[[BGTaskScheduler sharedScheduler] cancelAllTaskRequests] has been called")
    }
}

extension BackgroundTaskScheduler {
    func scheduleAppRefresh() throws {
        logger.debug("Requesting the BGAppRefreshTaskRequest for: \(Self.backgroundRefreshBackgroundTaskIdentifier)")
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshBackgroundTaskIdentifier)
        request.earliestBeginDate = Self.preferredBackgroundRefreshDate
        try BGTaskScheduler.shared.submit(request)
        
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"is.byeon.PRtify.background-refresh"]
        logger.debug("Submitted the BGAppRefreshTaskRequest for \(Self.backgroundRefreshBackgroundTaskIdentifier)")
    }
    
    @discardableResult
    func backgroundRefresh(by username: String) async -> Bool {
        logger.notice("Start the backgroundRefresh")
        
        defer {
            logger.notice("End the backgroundRefresh")
        }
        
        backgroundTimer = newBackgroundTimer(by: username)
        
        #if DEBUG
        do {
            let content = UNMutableNotificationContent()
            content.title = "[DEV] New background timer added!"
            content.subtitle = "preferredBackgroundTasksTimeInterval: \(Self.preferredBackgroundTasksTimeInterval)"
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logger.error("Error adding notification content from background refresh: \(error.localizedDescription)")
        }
        #endif
        
        return true
    }
}
