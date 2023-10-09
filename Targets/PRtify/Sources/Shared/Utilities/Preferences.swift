//
//  Preferences.swift
//  PRtify
//
//  Created by Insu Byeon on 10/10/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI
import Combine

final class Preferences: ObservableObject {
    @AppStorage("user") var user: User? = nil
}
