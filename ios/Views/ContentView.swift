//
//  ContentView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @Binding var user: User?
    
    var body: some View {
        if let user {
            Text("Hello nibs! \(user.name)")
            Button {
                
                GIDSignIn.sharedInstance.signOut()
                self.user = nil
            } label: {
                Text("Log out")
            }
        } else {
            LoginView(user: self.$user)
        }
    }
}

