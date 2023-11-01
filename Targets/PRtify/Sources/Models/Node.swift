//
//  Node.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import SwiftData

// @Model
public class Node: Codable {
    var url: URL
    var updatedAt: Date
    var createdAt: Date
    var title: String
    var number: Int
    var deletions: Int?
    var additions: Int?
    var reviews: Review
    var author: Author
    var repository: Repository
    var commits: CommitsNodes?
    var labels: Nodes<Label>
    var isDraft: Bool
    var isReadByViewer: Bool
    
    // swiftlint:disable line_length
    init(url: URL, updatedAt: Date, createdAt: Date, title: String, number: Int, deletions: Int?, additions: Int?, reviews: Review, author: Author, repository: Repository, commits: CommitsNodes?, labels: Nodes<Label>, isDraft: Bool, isReadByViewer: Bool) {
        self.url = url
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.title = title
        self.number = number
        self.deletions = deletions
        self.additions = additions
        self.reviews = reviews
        self.author = author
        self.repository = repository
        self.commits = commits
        self.labels = labels
        self.isDraft = isDraft
        self.isReadByViewer = isReadByViewer
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        title = try container.decode(String.self, forKey: .title)
        number = try container.decode(Int.self, forKey: .number)
        deletions = try container.decodeIfPresent(Int.self, forKey: .deletions)
        additions = try container.decodeIfPresent(Int.self, forKey: .additions)
        reviews = try container.decode(Review.self, forKey: .reviews)
        author = try container.decode(Author.self, forKey: .author)
        repository = try container.decode(Repository.self, forKey: .repository)
        commits = try container.decodeIfPresent(CommitsNodes.self, forKey: .commits)
        labels = try container.decode(Nodes<Label>.self, forKey: .labels)
        isDraft = try container.decode(Bool.self, forKey: .isDraft)
        isReadByViewer = try container.decode(Bool.self, forKey: .isReadByViewer)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(title, forKey: .title)
        try container.encode(number, forKey: .number)
        try container.encodeIfPresent(deletions, forKey: .deletions)
        try container.encodeIfPresent(additions, forKey: .additions)
        try container.encode(reviews, forKey: .reviews)
        try container.encode(author, forKey: .author)
        try container.encode(repository, forKey: .repository)
        try container.encodeIfPresent(commits, forKey: .commits)
        try container.encode(labels, forKey: .labels)
        try container.encode(isDraft, forKey: .isDraft)
        try container.encode(isReadByViewer, forKey: .isReadByViewer)
    }
    
    enum CodingKeys: String, CodingKey {
        case url
        case updatedAt
        case createdAt
        case title
        case number
        case deletions
        case additions
        case reviews
        case author
        case repository
        case commits
        case labels
        case isDraft
        case isReadByViewer
    }
    
    struct Repository: Codable {
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case name
        }
    }
    
    struct Nodes<T: Codable & Hashable>: Codable, Hashable {
        let nodes: [T]
        
        enum CodingKeys: String, CodingKey {
            case nodes
        }
    }
    
    struct Label: Codable, Hashable {
        var name: String
        var color: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case color
        }
    }
}

extension Node: Identifiable {
    public var id: String {
        [url.absoluteString, repository.name].joined(separator: "-")
    }
}
