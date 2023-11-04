//
//  CheckSuite.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct CheckSuite: Codable, Hashable {
    var app: App?
    var checkRuns: CheckRun
    
    enum CodingKeys: String, CodingKey {
        case checkRuns
        case app
    }
    
    struct App: Codable, Hashable {
        let name: String?
        enum CodingKeys: String, CodingKey {
            case name
        }
    }
}
