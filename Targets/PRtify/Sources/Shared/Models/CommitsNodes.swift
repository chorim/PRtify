//
//  CommitsNodes.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import SwiftData

@Model
class CommitsNodes: Codable {
    var nodes: [Commit]

    enum CodingKeys: String, CodingKey {
        case nodes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nodes = try container.decode([Commit].self, forKey: .nodes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodes, forKey: .nodes)
    }
}
