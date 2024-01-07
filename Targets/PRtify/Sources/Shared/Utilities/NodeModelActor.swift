//
//  NodeModelActor.swift
//  PRtify
//
//  Created by Insu Byeon on 1/7/24.
//  Copyright © 2024 is.byeon. All rights reserved.
//

import Foundation
import SwiftData

actor NodeModelActor: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelExecutor = {
            let context = ModelContext(modelContainer)
            return DefaultSerialModelExecutor(modelContext: context)
        }()
    }
    
    func insertAndDelete(nodes: [Node]) throws {
        try modelContext.delete(model: Node.self)
        
        for node in nodes {
            modelContext.insert(node)
        }
        
        try modelContext.save()
    }
    
    func nodesFromStorage() -> [Node] {
        let fetchDescriptor = FetchDescriptor<Node>()
        let nodeDescriptor = try? modelContext.fetch(fetchDescriptor)
        
        return nodeDescriptor ?? []
    }
}
