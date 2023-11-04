//
//  Search.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct Search: Codable {
    let edges: [Edge]
    let issueCount: Int
    
    enum CodingKeys: String, CodingKey {
        case edges
        case issueCount
    }
}
