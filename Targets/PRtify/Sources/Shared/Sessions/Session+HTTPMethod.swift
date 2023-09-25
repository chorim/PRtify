//
//  Session+HTTPMethod.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/01.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

extension Session {
    public enum HTTPMethod: String, CustomStringConvertible {
        case get
        case post
        case put
        case patch
        case delete

        public var description: String {
            rawValue.uppercased()
        }
    }
}
