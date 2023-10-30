//
//  BackgroundTaskScheduler.swift
//  PRtify
//
//  Created by Insu Byeon on 10/24/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import BackgroundTasks

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
        (16 / 2) * 60 // Fetch no earlier than 8 minutes from now
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
        return timerSource
    }
    
    func invalidate() {
        backgroundTimer = nil
        BGTaskScheduler.shared.cancelAllTaskRequests()
        logger.notice("[[BGTaskScheduler shared] cancelAllTaskRequests] has been called")
    }
}

extension BackgroundTaskScheduler {
    func scheduleAppRefresh() throws {
        logger.debug("Requesting the BGAppRefreshTaskRequest for: \(Self.backgroundRefreshBackgroundTaskIdentifier)")
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshBackgroundTaskIdentifier)
        request.earliestBeginDate = Self.preferredBackgroundRefreshDate
        try BGTaskScheduler.shared.submit(request)
        logger.debug("Submitted the BGAppRefreshTaskRequest for \(Self.backgroundRefreshBackgroundTaskIdentifier)")
    }
    
    @discardableResult
    func backgroundRefresh(by username: String, dataCleasing: Bool = false) async -> Bool {
        logger.notice("Start the backgroundRefresh")
        
        defer {
            logger.notice("End the backgroundRefresh")
        }
        
        backgroundTimer = newBackgroundTimer(by: username)
        
        return true
    }
}
