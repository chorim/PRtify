//
//  User.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/26.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

/// https://docs.github.com/en/free-pro-team@latest/rest/users/users?apiVersion=2022-11-28#get-the-authenticated-user--status-codes
public struct User: Identifiable, Codable {
    public let id: Int
    public let url: URL
    public let avatarURL: URL
    public let name: String
    
    public enum CodingKeys: String, CodingKey {
        case id
        case url
        case avatarURL = "avatar_url"
        case name
    }
}
