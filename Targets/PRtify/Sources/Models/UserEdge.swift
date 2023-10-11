//
//  UserEdge.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct UserEdge: Codable {
    var node: UserNode
    
    enum CondigKeys: String, CodingKey {
        case node
    }
}
