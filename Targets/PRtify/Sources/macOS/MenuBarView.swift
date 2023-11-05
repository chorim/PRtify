//
//  MenuBarView.swift
//  PRtify (macOS)
//
//  Created by Insu Byeon on 11/5/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct MenuBarView: View {
    var body: some View {
        
        Divider()
        
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Text("Quit")
        }
    }
}

#Preview {
    MenuBarView()
}
