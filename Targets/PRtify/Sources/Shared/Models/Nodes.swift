//
//  Nodes.swift
//  PRtify
//
//  Created by Insu Byeon on 11/8/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import SwiftData

@Model
class Nodes<T: Codable & Hashable>: Codable, Hashable {
    let nodes: [T]
    
    enum CodingKeys: String, CodingKey {
        case nodes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nodes = try container.decode([T].self, forKey: .nodes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodes, forKey: .nodes)
    }
}

