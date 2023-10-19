//
//  HomeNodeState.swift
//  PRtify
//
//  Created by Insu Byeon on 10/19/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

enum HomeNodeState {
    case loading
    case loaded([Node])
    case empty
}
