//
//  QueryGenerator.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import Foundation

// TODO: QueryGenerator will be replace the apollo client
public struct QueryGenerator {
    static func build(field: QuerySearchFieldType) -> String {
        let attended = """
            commits(last: 1) {
                nodes {
                    commit {
                        checkSuites(first: 10) {
                            nodes {
                                app {
                                    name
                                }
                                checkRuns(first: 10) {
                                    totalCount
                                    nodes {
                                        name
                                        conclusion
                                        detailsUrl
                                    }
                                }
                            }
                        }
                    }
                }
            }
        """
        
        let search = """
        {
           search(query: "\(field)", type: ISSUE, first: 30) {
               issueCount
               edges {
                   node {
                       ... on PullRequest {
                           number
                           createdAt
                           updatedAt
                           title
                           headRefName
                           url
                           deletions
                           additions
                           isDraft
                           isReadByViewer
                           author {
                               login
                               avatarUrl
                           }
                           repository {
                               name
                           }
                            labels(first: 5) {
                               nodes {
                                 name
                                 color
                               }
                             }
                           reviews(states: APPROVED, first: 10) {
                               totalCount
                               edges {
                                   node {
                                       author {
                                           login
                                       }
                                   }
                               }
                           }
                           \(attended)
                       }
                   }
               }
            }
        }
        """
        return search
    }
}

public enum QuerySearchFieldType: CustomStringConvertible {
    case created(username: String)
    case assigned(username: String)
    case requested(username: String)
    
    public var description: String {
        switch self {
        case .created(let username):
            return "is:open is:pr author:\(username) archived:false"
        case .assigned(let username):
            return "is:open is:pr assignee:\(username) archived:false"
        case .requested(let username):
            return "is:open is:pr review-requested:\(username) archived:false"
        }
    }
}
