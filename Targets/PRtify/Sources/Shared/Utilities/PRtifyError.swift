//
//  PRtifyError.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/25.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

struct PRtifyError {
    let error: LocalizedError
    
    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        self.error = localizedError
    }
}

extension PRtifyError: LocalizedError {
    var errorDescription: String? {
        error.errorDescription
    }
    
    var recoverySuggestion: String? {
        error.recoverySuggestion
    }
}
