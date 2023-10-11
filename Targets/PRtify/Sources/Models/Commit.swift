//
//  Commit.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct Commit: Codable, Hashable {
    var commit: CheckSuites
    
    enum CodingKeys: String, CodingKey {
        case commit
    }
}
