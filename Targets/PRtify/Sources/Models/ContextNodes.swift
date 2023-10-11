//
//  ContextNodes.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct ContextNodes: Codable, Hashable {
    var nodes: [ContextNode]
    
    enum CodingKeys: String, CodingKey {
        case nodes
    }
}

struct ContextNode: Codable, Hashable {
    var name: String?
    var context: String?
    var conclusion: String?
    var state: String?
    var title: String?
    var description: String?
    var detailsUrl: URL?
    var targetUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case context
        case conclusion
        case state
        case title
        case description
        case detailsUrl
        case targetUrl
    }
}
