//
//  RepositoriesAddView.swift
//  PRtify
//
//  Created by Insu Byeon on 10/3/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct RepositoriesAddView: View {
    @Binding var showingRepositoriesAddView: Bool
    
    @State private var text: String = ""
    
    var body: some View {
        List {
            TextField(text: $text) {
                Text("URL")
            }
            
            Button {
                self.showingRepositoriesAddView = false
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                    Text("Add")
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    RepositoriesAddView(showingRepositoriesAddView: .constant(true))
}
