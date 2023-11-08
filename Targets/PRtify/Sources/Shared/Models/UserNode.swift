//
//  UserNode.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import SwiftData

@Model
class UserNode: Codable {
    var author: User
    
    enum CodingKeys: String, CodingKey {
        case author
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        author = try container.decode(User.self, forKey: .author)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(author, forKey: .author)
    }
}
