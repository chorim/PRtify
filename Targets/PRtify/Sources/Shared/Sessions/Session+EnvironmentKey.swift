//
//  Session+EnvironmentKey.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/04.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import SwiftUI

struct SessionEnvironmentKey: EnvironmentKey {
    public static var defaultValue = Session.shared
}

extension EnvironmentValues {
   var session: Session {
       get { self[SessionEnvironmentKey.self] }
       set { self[SessionEnvironmentKey.self] = newValue }
   }
}
