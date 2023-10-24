//
//  PRtifyLabel.swift
//  PRtify
//
//  Created by Insu Byeon on 10/19/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct PRtifyLabel: LabelStyle {
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
