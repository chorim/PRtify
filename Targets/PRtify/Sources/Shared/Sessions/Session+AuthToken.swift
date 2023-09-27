//
//  Session+AuthToken.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/31.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

extension Session {
    public struct AuthToken: Codable {
        let accessToken: String
        let tokenType: TokenType

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
        }
    }

    public enum TokenType: String, Codable, CustomStringConvertible {
        case bearer
        
        public var description: String { rawValue.capitalized }
    }
}
