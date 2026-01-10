//
//  iosApp.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import GoogleSignIn
import SwiftUI

@main
struct DemoApp: App {
    @State var user: User?
    
    var body: some Scene {
        WindowGroup {
            ContentView(user: self.$user)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onAppear {
                GIDSignIn.sharedInstance.restorePreviousSignIn {user, error in
                    if let user {
                        self.user = .init(name: user.profile?.name ?? "")
                    }
                }
                
            }
        }
    }
}

struct User {
    var name: String
}
