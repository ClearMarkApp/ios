//
//  LoginView.swift
//  ios
//
//  Created by Lindsay Cheng on 2025-01-10.
//

import GoogleSignIn
import SwiftUI

struct LoginView: View {
    @Binding var user: GoogleUser?
    @StateObject private var createUserModel = CreateUserModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showCreateAccount = false
    @State private var pendingGoogleUser: (firstName: String, lastName: String, email: String)?
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // logo and header section
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.blue)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 8)
                    
                    Text("ClearMark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("AI-Powered Grading Assistant")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 32)
                }
                
//                // email and password form
//                VStack(alignment: .leading, spacing: 16) {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Email")
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundColor(.primary)
//                        
//                        TextField("professor@university.edu", text: $email)
//                            .textFieldStyle(PlainTextFieldStyle())
//                            .padding()
//                            .background(Color(.systemGray6))
//                            .cornerRadius(10)
//                            .autocapitalization(.none)
//                            .keyboardType(.emailAddress)
//                            .disabled(createUserModel.isLoading)
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Password")
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundColor(.primary)
//                        
//                        SecureField("Enter your password", text: $password)
//                            .textFieldStyle(PlainTextFieldStyle())
//                            .padding()
//                            .background(Color(.systemGray6))
//                            .cornerRadius(10)
//                            .disabled(createUserModel.isLoading)
//                    }
//                    
//                    if let error = errorMessage {
//                        Text(error)
//                            .font(.system(size: 14))
//                            .foregroundColor(.red)
//                    }
//                    
//                    HStack {
//                        Button(action: {
//                            // handle forgot password
//                        }) {
//                            Text("Forgot password?")
//                                .font(.system(size: 16))
//                                .foregroundColor(.blue)
//                        }
//                        .disabled(createUserModel.isLoading)
//                        Spacer()
//                    }
//                    .padding(.top, 4)
//                    
//                    Button(action: {
//                        handleEmailSignIn()
//                    }) {
//                        if createUserModel.isLoading {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 16)
//                        } else {
//                            Text("Sign In")
//                                .font(.system(size: 18, weight: .semibold))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 16)
//                        }
//                    }
//                    .background(Color.blue)
//                    .cornerRadius(10)
//                    .disabled(createUserModel.isLoading)
//                    .padding(.top, 16)
//                }
//                .padding(.horizontal, 32)
//                
//                HStack {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(height: 1)
//                    
//                    Text("or")
//                        .font(.system(size: 16))
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal, 12)
//                    
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(height: 1)
//                }
//                .padding(.horizontal, 32)
//                .padding(.vertical, 32)
                
                VStack(spacing: 16) {
                    Button(action: {
                        handleGoogleSignIn()
                    }) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 24, height: 24)
                            
                            Text("Continue with Google")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .disabled(createUserModel.isLoading)
                    
//                    Button(action: {
//                        handleGitHubSignIn()
//                    }) {
//                        HStack(spacing: 12) {
//                            Circle()
//                                .fill(Color.gray.opacity(0.3))
//                                .frame(width: 24, height: 24)
//                            
//                            Text("Continue with GitHub")
//                                .font(.system(size: 16, weight: .medium))
//                                .foregroundColor(.primary)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(10)
//                    }
//                    .disabled(createUserModel.isLoading)
                }
                .padding(.horizontal, 32)
//                
//                HStack(spacing: 4) {
//                    Text("Don't have an account?")
//                        .font(.system(size: 15))
//                        .foregroundColor(.secondary)
//                    
//                    Button(action: {
//                        // handle contact institution
//                    }) {
//                        Text("Contact your institution")
//                            .font(.system(size: 15))
//                            .foregroundColor(.blue)
//                    }
//                }
//                .padding(.top, 40)
//                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showCreateAccount) {
            if let pendingUser = pendingGoogleUser {
                CreateAccountView(
                    firstName: pendingUser.firstName,
                    lastName: pendingUser.lastName,
                    email: pendingUser.email,
                    onAccountCreated: { createdUser in
                        showCreateAccount = false
                        user = createdUser
                        pendingGoogleUser = nil
                    },
                    onCancel: {
                        showCreateAccount = false
                        pendingGoogleUser = nil
                    }
                )
            }
        }
    }
    
    func handleEmailSignIn() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }
        
        print("email sign in clicked - email: \(email)")
        // TODO: Implement actual email/password authentication
    }
    
    func handleGoogleSignIn() {
        print("sign in with google clicked")
        
        if let rootViewController = getRootViewController() {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            ) { result, error in
                guard let result else {
                    return
                }
                
                let firstName = result.user.profile?.givenName ?? ""
                let lastName = result.user.profile?.familyName ?? ""
                let email = result.user.profile?.email ?? ""
                
                Task { @MainActor in
                    await checkAndHandleUser(firstName: firstName, lastName: lastName, email: email)
                }
            }
        }
    }
    
    @MainActor
    func checkAndHandleUser(firstName: String, lastName: String, email: String) async {
        createUserModel.isLoading = true
        errorMessage = nil

        let checker = CheckUserExistsModel()
        let exists = await checker.checkUserExists(email: email)

        createUserModel.isLoading = false

        if exists {
            // User exists, proceed with login
            self.user = GoogleUser(
                firstName: firstName,
                lastName: lastName,
                email: email
            )
        } else {
            // User doesn't exist, show create account
            pendingGoogleUser = (firstName, lastName, email)
            showCreateAccount = true
        }
    }
    
    func handleGitHubSignIn() {
        print("sign in with github clicked")
        // implement github authentication here
    }
}

private func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = scene.windows.first?.rootViewController else {
        return nil
    }
    return getVisibleViewController(from: rootViewController)
}

private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
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
