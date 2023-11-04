//
//  Edges.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct Edges: Codable {
    let edge: [Edge]
    
    enum CodingKeys: String, CodingKey {
        case edge
    }
}

struct Edge: Codable {
    let node: Node

    enum CodingKeys: String, CodingKey {
        case node
    }
}
