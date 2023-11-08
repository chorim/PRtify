//
//  Review.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import SwiftData

@Model
class Review: Codable {
    var totalCount: Int
    var edges: [UserEdge]
    
    enum CodingKeys: String, CodingKey {
        case totalCount
        case edges
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalCount = try container.decode(Int.self, forKey: .totalCount)
        edges = try container.decode([UserEdge].self, forKey: .edges)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalCount, forKey: .totalCount)
        try container.encode(edges, forKey: .edges)
    }
}
