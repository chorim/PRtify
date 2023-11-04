//
//  UserNode.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct UserNode: Codable {
    var author: User
    
    enum CodingKeys: String, CodingKey {
        case author
    }
}
