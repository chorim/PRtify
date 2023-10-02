//
//  RepositoriesView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/28.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct RepositoriesListView: View {
    @Binding var showingRepositoriesAddView: Bool
    
    var body: some View {
        Section {
            Text("Hello")
        } header: {
            HStack {
                Text("Repositories")
                Spacer()
                Button {
                    self.showingRepositoriesAddView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    RepositoriesListView(showingRepositoriesAddView: .constant(false))
}
