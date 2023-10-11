//
//  Graph.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct Graph: Codable {
    let data: Data
    
    enum CodingKeys: String, CodingKey {
        case data
    }

    struct Data: Codable {
        let search: Search

        enum CodingKeys: String, CodingKey {
            case search
        }
    }
}
