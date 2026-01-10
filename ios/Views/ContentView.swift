//
//  ContentView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI
import GoogleSignIn

/*
struct ContentView: View {
    var body: some View {
        var email = "test@test.com"
        
        if (email.isEmpty) {
            LoginView()
        } else {
            HomeView()
        }
    }
}
*/

struct ContentView: View {
    @Binding var user: GoogleUser?
    
    var body: some View {
        if let user {
            HomeView(user: self.$user)
        } else {
            LoginView(user: self.$user)
        }
    }
}

