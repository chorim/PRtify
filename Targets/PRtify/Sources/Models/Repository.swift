//
//  Repository.swift
//  PRtify
//
//  Created by Insu Byeon on 10/3/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import SwiftData

@Model
class Repository {
    var url: URL
    var createdAt: Date
    var updatedAt: Date
    var status: RepositoryStatus
    
    init(url: URL) {
        self.url = url
        self.createdAt = .now
        self.updatedAt = .now
        self.status = .underlying
    }
}

enum RepositoryStatus: Int, Codable {
    case underlying = 0
    case connected = 1
    case disconnected = 2
}
