//
//  LatestRelease.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct LatestRelease: Codable {
    var name: String
    var assets: [Asset]
    
    enum CodingKeys: String, CodingKey {
        case name
        case assets
    }
    
    struct Asset: Codable {
        var name: String
        var browserDownloadUrl: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case browserDownloadUrl = "browser_download_url"
        }
    }
}
