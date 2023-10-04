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
    public let login: String
    public let url: URL
    public let avatarURL: URL
    public let name: String?
    public let company: String?
    public let blog: String?
    public let location: String?
    public let email: String?
    public let bio: String?
    public let followers: Int
    public let following: Int
    
    public enum CodingKeys: String, CodingKey {
        case id
        case login
        case url
        case avatarURL = "avatar_url"
        case name
        case company
        case blog
        case location
        case email
        case bio
        case followers
        case following
    }
}

extension User {
    static var mock: Self {
        return User(
            id: 11539551,
            login: "chorim",
            url: URL(string: "https://api.github.com/users/chorim")!,
            avatarURL: URL(string: "https://avatars.githubusercontent.com/u/11539551?v=4")!,
            name: "Insu Byeon",
            company: "@RxSwiftCommunity ",
            blog: "https://byeon.is",
            location: "Seoul, South Korea",
            email: "me@byeon.is",
            bio: "iOS Developer",
            followers: 44,
            following: 43
        )
    }
}
