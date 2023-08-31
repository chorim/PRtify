//
//  URL+Github.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/31.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

public extension URL {
    static let githubAPI: URL = URL(string: "https://api.github.com/")!
    
    init?(githubAPIWithPath path: String) {
        self.init(string: path, relativeTo: Self.githubAPI)
    }
}
