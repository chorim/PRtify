//
//  Session+Scopes.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/31.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

extension Session {
    public enum Scopes: String, CustomStringConvertible {
        case repo
        case user
        
        public var description: String {
            rawValue
        }
    }
}
