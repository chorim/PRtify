//
//  Color+PRtify.swift
//  PRtify
//
//  Created by Insu Byeon on 10/7/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

#if os(macOS)
typealias PRtifyColor = NSColor
#elseif os(iOS)
typealias PRtifyColor = UIColor
#endif

extension Color {
    static let flatDarkBackground = Color(.flatDarkBackground)
    static let flatDarkCardBackground = Color(.flatDarkCardBackground)
    static let flatDarkContainerBackground = Color(.flatDarkContainerBackground)
}

extension PRtifyColor {
    static let flatDarkBackground = PRtifyColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 1)
    static let flatDarkCardBackground = PRtifyColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1)
    static let flatDarkContainerBackground = PRtifyColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
}
