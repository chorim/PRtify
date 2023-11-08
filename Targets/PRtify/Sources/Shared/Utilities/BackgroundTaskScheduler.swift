//
//  BackgroundTaskScheduler.swift
//  PRtify
//
//  Created by Insu Byeon on 10/24/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
#if os(iOS)
import BackgroundTasks
#endif
import UserNotifications
import SwiftUI
import SwiftData

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
    
    init(session: Session, context: ModelContext? = nil) {
        self.session = session
        self.mainContext = context
    }
    
    public static let backgroundRefreshBackgroundTaskIdentifier: String =
        "\(Bundle.prtify.bundleIdentifier!).background-refresh"
    public static let dataCleansingBackgroundTaskIdentifier: String =
        "\(Bundle.prtify.bundleIdentifier!).data-cleansing"
    
    public var mainContext: ModelContext?
    
    static var preferredBackgroundTasksTimeInterval: TimeInterval {
        #if DEBUG
        60
        #else
        (16 / 2) * 60 // Fetch no earlier than 8 minutes from now
        #endif
    }
    
    static var preferredBackgroundRefreshDate: Date {
        Date(timeIntervalSinceNow: preferredBackgroundTasksTimeInterval)
    }
    
    // swiftlint:disable function_body_length
    func newBackgroundTimer(by username: String) -> DispatchSourceTimer {
        let timerSource = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        timerSource.setEventHandler {
            Task {
                do {
                    let nodes = try await self.session.fetchPullRequests(by: username)
                    
                    guard let mainContext = self.mainContext else { fatalError("mainContext is nil") }
                    
                    var fetchDescriptor = FetchDescriptor<Node>()
                    // fetchDescriptor.sortBy = [\Node.createdAt]
                    let nodesFromDescriptor = try mainContext.fetch(fetchDescriptor)
                    
                    var numberOfGraph: Int = 0
                    for node in nodes {
                        numberOfGraph += node.value.count
                    }
                    
                    if nodesFromDescriptor.count != numberOfGraph {
                        let content = UNMutableNotificationContent()
                        content.title = "New pull request exists!"
                        content.subtitle = "Check it now!"
                        let request = UNNotificationRequest(
                            identifier: UUID().uuidString,
                            content: content,
                            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        )
                        try? await UNUserNotificationCenter.current().add(request)
                    }
                    
                    // Clean node data
                    try mainContext.delete(model: Node.self)
                    
                    for node in nodes {
                        let graphs = node.value
                        
                        for graph in graphs {
                            mainContext.insert(graph)
                        }
                    }
                    
                    try mainContext.save()
                    
                    #if DEBUG
                    let content = UNMutableNotificationContent()
                    content.title = "[DEV] New pull request from background task!"
                    content.subtitle = "1 Check it now!"
                    let request = UNNotificationRequest(
                        identifier: UUID().uuidString,
                        content: content,
                        trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                    )
                    try? await UNUserNotificationCenter.current().add(request)
                    #endif
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
        logger.notice("New background timer has been created: \(String(describing: timerSource))")
        return timerSource
    }
    
    func invalidate() {
        #if os(iOS)
        BGTaskScheduler.shared.getPendingTaskRequests { all in
            self.logger.notice("Pending Tasks Requests: \(String(describing: all))")
        }
        #endif
        backgroundTimer = nil
        logger.notice("The background timer has been cancelled.")
        #if os(iOS)
        BGTaskScheduler.shared.cancelAllTaskRequests()
        logger.notice("[[BGTaskScheduler sharedScheduler] cancelAllTaskRequests] has been called")
        #endif
    }
}

public extension BackgroundTaskScheduler {
    func scheduleAppRefresh(by username: String, using phase: ScenePhase) throws {
        switch phase {
        case .active, .inactive:
            invalidate()
            
        case .background:
            backgroundTimer = newBackgroundTimer(by: username)
            
            #if os(iOS)
            logger.debug("Requesting the BGAppRefreshTaskRequest for: \(Self.backgroundRefreshBackgroundTaskIdentifier)")
            
            let request = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshBackgroundTaskIdentifier)
            request.earliestBeginDate = Self.preferredBackgroundRefreshDate
            try BGTaskScheduler.shared.submit(request)
            
            // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"is.byeon.PRtify.background-refresh"]
            logger.debug("Submitted the BGAppRefreshTaskRequest for \(Self.backgroundRefreshBackgroundTaskIdentifier)")
            
            #if DEBUG
            Task {
                let content = UNMutableNotificationContent()
                content.title = "[DEV] Submitted the BGAppRefreshTaskRequest for \(Self.backgroundRefreshBackgroundTaskIdentifier)!"
                content.subtitle = "preferredBackgroundTasksTimeInterval: \(Self.preferredBackgroundTasksTimeInterval)"
                let notificationRequest = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                )
                try await UNUserNotificationCenter.current().add(notificationRequest)
            }
            #endif
            #endif

        @unknown default:
            logger.critical("Unknown ScenePhase: \(String(describing: phase))")
            fatalError("Unknown ScenePhase: \(String(describing: phase))")
        }
    }
    
    @discardableResult
    func backgroundRefresh(by username: String) async -> Bool {
        #if os(macOS)
        // Only macOS
        backgroundTimer = newBackgroundTimer(by: username)
        #endif
        
        do {
            // Only iOS
            #if os(iOS)
            // try await ...
            #endif
            try scheduleAppRefresh(by: username, using: .background)
            #if DEBUG
            let content = UNMutableNotificationContent()
            content.title = "[DEV] New pull request from background task!"
            content.subtitle = "0 Check it now!"
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
            try await UNUserNotificationCenter.current().add(request)
            #endif
        } catch {
            logger.error("Error retrieving data from background scheduler: \(error.localizedDescription)")
            return false
        }

        return true
    }
}
