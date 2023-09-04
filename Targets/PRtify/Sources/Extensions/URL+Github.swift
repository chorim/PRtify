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
    
    init?(githubAPIWithPath path: String, isRoot: Bool = false) {
        if isRoot {
            self.init(string: path, relativeTo: Self.githubAPI.rootDomain)
        } else {
            self.init(string: path, relativeTo: Self.githubAPI)
        }
    }
}

fileprivate extension URL {
    var rootDomain: URL? {
        guard let scheme = self.scheme else { return nil }
        guard let hostName = self.host else { return nil }
        
        let components = hostName.components(separatedBy: ".")
        
        let urlString = components.count > 2 ? components.suffix(2).joined(separator: ".") : hostName
        
        return URL(string: "\(scheme)://" + urlString)
    }
}
