//
//  PRtifyPreviewContainer.swift
//  PRtify
//
//  Created by Insu Byeon on 10/4/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI
import SwiftData

@MainActor
let PRtifyPreviewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Node.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        // let repository = Repository(url: URL(string: "https://github.com/chorim/PRtify")!)
        // container.mainContext.insert(repository)
        
        return container
    } catch {
        fatalError("Failed to create the preview container.")
    }
}()
