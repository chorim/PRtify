//
//  HomeView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/26.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct HomeView: View, Loggable {
    @Binding var authToken: Session.AuthToken?
    
    var body: some View {
        VStack {
            Text("Hello, Home!")
            
            Button {
                authToken = nil
                logger.info("Sign out")
            } label: {
                Text("Sign Out")
            }
        }
    }
}

#Preview {
    HomeView(authToken: .constant(nil))
}
