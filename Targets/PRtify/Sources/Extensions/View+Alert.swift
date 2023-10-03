//
//  View+Alert.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/25.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

extension View {
    func alert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        let localizedError = PRtifyError(error: error.wrappedValue)
        let isPresented = Binding.constant(localizedError != nil)
        
        return alert(isPresented: isPresented, error: localizedError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "Unknown Error")
        }
    }
}
