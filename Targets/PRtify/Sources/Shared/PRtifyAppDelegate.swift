//
//  PRtifyAppDelegate.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/01.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

@MainActor
class PRtifyAppDelegate: NSObject, ObservableObject {
    let session = Session.shared
    
    override init() {
        super.init()
    }
}
