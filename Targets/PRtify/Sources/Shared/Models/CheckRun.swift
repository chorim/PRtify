//
//  CheckRun.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct CheckRun: Codable, Hashable {
    let totalCount: Int
    let nodes: [Check]
    
    enum CodingKeys: String, CodingKey {
        case totalCount
        case nodes
    }
    
    struct Check: Codable, Hashable {
        var name: String
        var conclusion: String?
        var detailsUrl: URL
        
        enum CodingKeys: String, CodingKey {
            case name
            case conclusion
            case detailsUrl
        }
    }
}
