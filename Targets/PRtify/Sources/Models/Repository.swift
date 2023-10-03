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
    
    init(url: URL, createdAt: Date = .now, updatedAt: Date = .now) {
        self.url = url
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
