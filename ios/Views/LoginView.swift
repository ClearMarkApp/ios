//
//  ContentView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @Binding var user: User?
    
    var body: some View {
        VStack {
            Text("Log in screen")
            Button {
                handleSignupButton()
            } label: {
                Text("log in with Google")
            }
        }
        .padding(.vertical, 80)
    }
    
    func handleSignupButton() {
        print("sign in with google clicked")
        
        if let rootViewController = getRootViewController() {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            ) { result, error in
                guard let result else {
                    // inspect error
                    return
                }
                self.user = User.init(name: result.user.profile?.name ?? "")
            }
        }
    }
}

func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as?
            UIWindowScene,
          let rootViewController = scene.windows.first?.rootViewController else {
        return nil
    }
    return getVisibleViewController(from: rootViewController)
}

private func getVisibleViewController(from vc: UIViewController) ->
UIViewController {
    if let nav = vc as? UINavigationController {
        return getVisibleViewController(from: nav.visibleViewController!)
    }
    if let tab = vc as? UITabBarController {
        return getVisibleViewController(from: tab.selectedViewController!)
    }
    if let presented = vc.presentedViewController {
        return getVisibleViewController(from: presented)
    }
    return vc
}

