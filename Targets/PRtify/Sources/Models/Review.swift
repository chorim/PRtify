//
//  Review.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct Review: Codable {
    var totalCount: Int
    var edges: [UserEdge]
    
    enum CodingKeys: String, CodingKey {
        case totalCount
        case edges
    }
}
