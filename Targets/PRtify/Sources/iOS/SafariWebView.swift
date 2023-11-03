//
//  SafariWebView.swift
//  PRtify
//
//  Created by Insu Byeon on 10/31/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

#Preview {
    SafariWebView(url: URL(string: "https://apple.com")!)
}
