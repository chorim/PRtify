//
//  Node.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct Node: Codable {
    let url: URL
    let updatedAt: Date
    let createdAt: Date
    let title: String
    let number: Int
    let deletions: Int?
    let additions: Int?
    let reviews: Review
    let author: Author
    let repository: Repository
    let commits: CommitsNodes?
    let labels: Nodes<Label>
    let isDraft: Bool
    let isReadByViewer: Bool
    
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
