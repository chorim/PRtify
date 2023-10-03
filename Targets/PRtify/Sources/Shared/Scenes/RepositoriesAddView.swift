//
//  RepositoriesAddView.swift
//  PRtify
//
//  Created by Insu Byeon on 10/3/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct RepositoriesAddView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var showingRepositoriesAddView: Bool
    
    @State private var text: String = ""
    
    var body: some View {
        List {
            TextField(text: $text) {
                Text("URL")
            }
            
            Button {
                self.add()
                self.showingRepositoriesAddView = false
            } label: {
                HStack {
                    Spacer()
                    Label("Add", systemImage: "plus")
                    Spacer()
                }
            }
        }
    }
    
    func add() {
        guard let url = URL(string: text) else { return }
        let repository = Repository(url: url)
        modelContext.insert(repository)
    }
}

#Preview {
    RepositoriesAddView(showingRepositoriesAddView: .constant(true))
}
