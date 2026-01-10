//
//  iosApp.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import GoogleSignIn
import SwiftUI

@main
struct iosApp: App {
    @State var user: GoogleUser?
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(user: self.$user)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onAppear {
                GIDSignIn.sharedInstance.restorePreviousSignIn { gidUser, error in
                    if let gidUser {
                        self.user = .init(
                            firstName: gidUser.profile?.givenName ?? "",
                            lastName: gidUser.profile?.familyName ?? "",
                            email: gidUser.profile?.email ?? ""
                        )
                    }
                }
            }
        }
    }
}
