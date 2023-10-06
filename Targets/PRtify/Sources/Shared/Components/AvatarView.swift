//
//  AvatarView.swift
//  PRtify
//
//  Created by Insu Byeon on 10/5/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation
import SwiftUI

struct AvatarView: View {
    @Binding var avatarURL: URL
    
    @Environment(\.avatarViewStyle)
    var style: AvatarViewStyle
    
    var body: some View {
        AsyncImage(
            url: avatarURL,
            content: { image in
                image
                    .resizable()
                    .frame(maxWidth: style.size.width, maxHeight: style.size.height)
                    .scaledToFill()
                    .clipShape(Circle())
            },
            placeholder: {
                ProgressView()
            }
        )
    }
}

enum AvatarViewStyle {
    case small
    case large
    
    var size: CGSize {
        switch self {
        case .small:
            return .init(width: 42, height: 42)
        case .large:
            return .init(width: 96, height: 96)
        }
    }
}

private struct AvatarViewStyleKey: EnvironmentKey {
    static let defaultValue: AvatarViewStyle = .small
}

extension EnvironmentValues {
    var avatarViewStyle: AvatarViewStyle {
        get { self[AvatarViewStyleKey.self] }
        set { self[AvatarViewStyleKey.self] = newValue }
    }
}

extension View {
    func avatarViewStyle(_ style: AvatarViewStyle) -> some View {
        environment(\.avatarViewStyle, style)
    }
}

#Preview {
    AvatarView(avatarURL: .constant(User.mock.avatarURL))
}
