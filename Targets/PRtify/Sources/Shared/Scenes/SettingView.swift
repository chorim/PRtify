//
//  SettingView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/26.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.flatDarkBackground.edgesIgnoringSafeArea([.all])
            }
            .navigationTitle("Settings")
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingView()
}
