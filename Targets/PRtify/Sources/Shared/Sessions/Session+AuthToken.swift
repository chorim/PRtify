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

    public enum TokenType: String, Codable {
        case bearer
    }
}

extension Optional: RawRepresentable where Wrapped == Session.AuthToken {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Session.AuthToken.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Session.AuthToken.CodingKeys.self)
        try container.encode(self?.accessToken, forKey: .accessToken)
        try container.encode(self?.tokenType, forKey: .tokenType)
    }
}
