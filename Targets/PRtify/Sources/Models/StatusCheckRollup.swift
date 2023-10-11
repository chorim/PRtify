//
//  StatusCheckRollup.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct StatusCheckRollup: Codable, Hashable {
    var state: String
    var contexts: ContextNodes
    
    enum CodingKeys: String, CodingKey {
        case state
        case contexts
    }
}
