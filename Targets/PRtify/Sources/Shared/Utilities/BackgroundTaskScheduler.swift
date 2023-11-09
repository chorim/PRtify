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
    
    #if os(macOS)
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
    #endif
    
    init(session: Session, context: ModelContext? = nil) {
        self.session = session
        self.mainContext = context
    }
    
    public static let backgroundRefreshBackgroundTaskIdentifier: String =
        "\(Bundle.prtify.bundleIdentifier!).background-refresh"
    
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
    
    func newBackgroundTimer(by username: String) -> DispatchSourceTimer {
        let timerSource = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        timerSource.setEventHandler {
            Task {
                do {
                    let hasNewPullRequest = await self.hasNewPullRequest(by: username)
                    if hasNewPullRequest {
                        try await self.notifyUser()
                    }
                    
                    #if DEBUG
                    await self.notifyForDebug("[DEV] DispatchSourceTimer has been executed!", message: "hasNewPullRequest: \(hasNewPullRequest)")
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
        BGTaskScheduler.shared.cancelAllTaskRequests()
        logger.notice("[[BGTaskScheduler sharedScheduler] cancelAllTaskRequests] has been called")
        #elseif os(macOS)
        backgroundTimer = nil
        logger.notice("The background timer has been cancelled.")
        #endif
    }
}

public extension BackgroundTaskScheduler {
    func scheduleAppRefresh(by username: String, using phase: ScenePhase) throws {
        switch phase {
        case .active, .inactive:
            invalidate()
            
        case .background:
            #if os(iOS)
            logger.debug("Requesting the BGAppRefreshTaskRequest for: \(Self.backgroundRefreshBackgroundTaskIdentifier)")
            
            let request = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshBackgroundTaskIdentifier)
            request.earliestBeginDate = Self.preferredBackgroundRefreshDate
            try BGTaskScheduler.shared.submit(request)
            
            // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"is.byeon.PRtify.background-refresh"]
            logger.debug("Submitted the BGAppRefreshTaskRequest for \(Self.backgroundRefreshBackgroundTaskIdentifier)")
            
            #if DEBUG
            Task {
                await notifyForDebug("[DEV] Submitted the BGAppRefreshTaskRequest for \(Self.backgroundRefreshBackgroundTaskIdentifier)!", message: "preferredBackgroundTasksTimeInterval: \(Self.preferredBackgroundTasksTimeInterval)")
            }
            #endif
            #elseif os(macOS)
            backgroundTimer = newBackgroundTimer(by: username)
            #else
            fatalError("Unsupported platform.")
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
            let hasNewPullRequest = await hasNewPullRequest(by: username)
            
            if hasNewPullRequest {
                try await notifyUser()
            }
            #endif
            try scheduleAppRefresh(by: username, using: .background)
        } catch {
            logger.error("Error retrieving data from background scheduler: \(error.localizedDescription)")
            return false
        }

        return true
    }
}

// MARK: FetchDescriptor
private extension BackgroundTaskScheduler {
    func hasNewPullRequest(by username: String) async -> Bool {
        do {
            var nodes: [Node] = []
            
            for graph in try await self.session.fetchPullRequests(by: username) {
                nodes += graph.value
            }
                        
            var _nodes: [Node] = []
            _nodes = nodes

            defer {
                // Clean node data
                try? mainContext?.delete(model: Node.self)
                
                // Save new node data
                for node in _nodes {
                    mainContext?.insert(node)
                }
                
                try? mainContext?.save()
            }
            
            // Return the true If empty
            guard !nodeFromStorage.isEmpty else { return false }

            for node in nodeFromStorage {
                nodes.removeAll(where: { $0.id == node.id })
            }
            
            return nodes.count >= 1
        } catch {
            logger.error("\(username)'s hasNewPullRequest error: \(error.localizedDescription)")
        }
        
        return false
    }
    
    var nodeFromStorage: [Node] {
        let fetchDescriptor = FetchDescriptor<Node>()
        let nodeDescriptor = try? mainContext?.fetch(fetchDescriptor)
        
        return nodeDescriptor ?? []
    }
    
    func notifyUser() async throws {
        let content = UNMutableNotificationContent()
        content.title = "New pull request exists!"
        content.subtitle = "Check it now!"
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        try await UNUserNotificationCenter.current().add(request)
    }
}

#if DEBUG
private extension BackgroundTaskScheduler {
    func notifyForDebug(_ title: String, message: String = "") async {
        do {
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = message
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logger.error("notifyForDebug error: \(error.localizedDescription)")
        }
    }
}
#endif
