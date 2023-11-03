//
//  PRtifyAppDelegate+NSApplicationDelegate.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/04.
//  Copyright © 2023 tuist.io. All rights reserved.
//

#if os(macOS)
import AppKit
import UserNotifications

extension PRtifyAppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
}
#endif
