//
//  UserEdge.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import SwiftData

@Model
class UserEdge: Codable {
    var node: UserNode
    
    enum CodingKeys: String, CodingKey {
        case node
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        node = try container.decode(UserNode.self, forKey: .node)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(node, forKey: .node)
    }
}
