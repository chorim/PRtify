//
//  ProfileView.swift
//  PRtify
//
//  Created by Insu Byeon on 10/4/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @Binding var user: User
    
    var body: some View {
        ZStack {
            Color.flatDarkBackground.edgesIgnoringSafeArea([.all])
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        AvatarView(avatarURL: user.avatarURL)
                            .avatarViewStyle(.large)
                        
                        VStack(alignment: .leading) {
                            Text("\(user.name ?? "Empty Name")")
                                .font(.largeTitle)

                            Text("@\(user.login)")
                                .font(.headline)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    
                    if let bio = user.bio {
                        Text(bio)
                            .padding([.top, .bottom], 10)
                    }
                    
                    if let company = user.company {
                        HStack {
                            Image(systemName: "building.2")
                            Text(company)
                                .fontWeight(.semibold)
                        }
                        .padding([.top, .bottom], 2)
                    }
                    
                    if let location = user.location {
                        HStack {
                            Image(systemName: "location")
                            Text(location)
                        }
                        .padding([.top, .bottom], 2)
                    }
                    
                    if let email = user.email {
                        HStack {
                            Image(systemName: "mail")
                            Text(email)
                        }
                        .padding([.top, .bottom], 2)
                    }
                    
                    HStack {
                        Image(systemName: "person")
                        Text("\(user.followers) followers")
                        Text("\(user.following) following")
                        Spacer()
                    }
                    .padding([.top, .bottom], 2)
                }
                .padding(.all, 24)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ProfileView(user: .constant(.mock))
}
