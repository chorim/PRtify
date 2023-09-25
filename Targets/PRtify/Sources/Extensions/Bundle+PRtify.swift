//
//  Bundle+PRtify.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/30.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

extension Bundle {
    private class BundleFinder {}

    static var prtify: Self {
        self.init(for: BundleFinder.self)
    }
}
