//
//  PullRequestView.swift
//  PRtify
//
//  Created by Insu Byeon on 10/19/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct PullRequestView: View {
    var node: Node
    
    private var avatarURL: URL {
        node.author.avatarURL
    }
    
    private var name: String {
        node.title
    }
    
    private var issueNumber: String {
        "#\(node.number)"
    }
    
    private var repositoryName: String {
        node.repository.name
    }
    
    private var authorName: String {
        node.author.login
    }
    
    @ViewBuilder
    var reviewsLabel: some View {
        Label("\(node.reviews.edges.count)", systemImage: "checkmark.circle")
            .foregroundStyle(.gray)
    }
    
    @ViewBuilder
    var additionsLabel: some View {
        Text("+\(node.additions ?? 0)")
            .foregroundStyle(.green)
    }
    
    @ViewBuilder
    var deletionsLabel: some View {
        Text("+\(node.deletions ?? 0)")
            .foregroundStyle(.red)
    }
    
    var body: some View {
        HStack {
            AvatarView(avatarURL: Binding { avatarURL } set: { _ in })
            
            VStack(alignment: .leading, spacing: 5) {
                // pr name
                HStack(alignment: .top, spacing: 0) {
                    Text(name)
                        .lineLimit(1)
                    Text(issueNumber)
                        .foregroundStyle(.gray)
                    Spacer()
                }
                
                // repo name
                HStack(alignment: .center, spacing: 5) {
                    Label(repositoryName, systemImage: "text.book.closed")
                        .labelStyle(PRtifyLabel(spacing: 2))
                    Label(authorName, systemImage: "person")
                        .labelStyle(PRtifyLabel(spacing: 2))
                    Spacer()
                }
                .foregroundStyle(.gray)
                
                // diff label
                HStack(alignment: .center, spacing: 0) {
                    reviewsLabel
                        .labelStyle(PRtifyLabel(spacing: 2))
                        .padding(.trailing, 5)
                    additionsLabel
                    deletionsLabel
                    Spacer()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    PullRequestView(node: .mock)
        .preferredColorScheme(.dark)
}

fileprivate extension Node {
    static var mock: Self {
        let data = """
            {
                "number": 1981,
                "createdAt": "2021-04-06T08:11:24Z",
                "updatedAt": "2021-04-08T08:26:38Z",
                "title": "Use forEach instead of map method in example",
                "headRefName": "patch-1",
                "url": "https://github.com/TextureGroup/Texture/pull/1981",
                "deletions": 12,
                "additions": 12,
                "isDraft": false,
                "isReadByViewer": true,
                "author": {
                    "login": "chorim",
                    "avatarUrl": "https://avatars.githubusercontent.com/u/11539551?u=4ec1a9ed810c88f006b00066e3f46a0eac247e75&v=4"
                },
                "repository": {
                    "name": "Texture"
                },
                "labels": {
                    "nodes": []
                },
                "reviews": {
                    "totalCount": 0,
                    "edges": []
                },
                "commits": {
                    "nodes": [
                        {
                            "commit": {
                                "checkSuites": {
                                    "nodes": []
                                }
                            }
                        }
                    ]
                }
            }
            """.data(using: .utf8)!
        
        // swiftlint:disable force_try
        return try! URLSession.decoder.decode(Node.self, from: data)
    }
}
