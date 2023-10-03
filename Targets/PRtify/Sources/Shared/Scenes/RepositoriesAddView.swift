//
//  RepositoriesAddView.swift
//  PRtify
//
//  Created by Insu Byeon on 10/3/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct RepositoriesAddView: View, Loggable {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var showingRepositoriesAddView: Bool
    
    @State private var error: Error?
    @State private var text: String = ""
    
    var body: some View {
        List {
            TextField(text: $text) {
                Text("URL")
            }
            
            Section {
                addButton
            }
        }
        .alert(error: $error)
    }
    
    func add() throws {
        guard let url = URL(string: text) else {
            logger.error("Invalid the url: \(text)")
            throw PRtifyURLError.invalidURL
        }
        
        let repository = Repository(url: url)
        modelContext.insert(repository)
    }
    
    @ViewBuilder
    var addButton: some View {
        Button {
            do {
                try self.add()
                self.showingRepositoriesAddView = false
            } catch {
                self.error = error
                logger.error("An error occurred while performing add: \(error.localizedDescription)")
            }
        } label: {
            HStack {
                Spacer()
                Label("Add", systemImage: "plus")
                Spacer()
            }
        }
    }
}

#Preview {
    RepositoriesAddView(showingRepositoriesAddView: .constant(true))
}
