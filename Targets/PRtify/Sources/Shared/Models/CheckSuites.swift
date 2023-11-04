//
//  CheckSuites.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct CheckSuites: Codable, Hashable {
    var checkSuites: CheckSuitsNodes?
    var statusCheckRollup: StatusCheckRollup?
    
    enum CodingKeys: String, CodingKey {
        case checkSuites
        case statusCheckRollup
    }
}
