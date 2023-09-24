//
//  Logger.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/25.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import OSLog

protocol Loggable {
    var logger: Logger { get }
}

extension Loggable {
    var logger: Logger {
        Logger(category: String(describing: type(of: self)))
    }
}

extension Logger {
    private static var subsystem: String = Bundle.main.bundleIdentifier!
    
    init(category: String) {
        self.init(subsystem: Self.subsystem, category: category)
    }
}

extension Logger {
    func export(scope: OSLogStore.Scope = .currentProcessIdentifier) throws -> [String] {
        let store = try OSLogStore(scope: scope)
        let position = store.position(timeIntervalSinceLatestBoot: 1)
        let entries = try store.getEntries(at: position)
            .compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == Bundle.main.bundleIdentifier! }
            .map { "[\($0.date.formatted())] [\($0.category)] \($0.composedMessage)" }
        
        return entries
    }
}

extension Session: Loggable {}

