//
//  CreateAccountView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct CreateAccountView: View {
    @StateObject private var createUserModel = CreateUserModel()
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String

    let title: String
    let subtitle: String
    let accountType: UsersAccountType
    let onAccountCreated: (GoogleUser) -> Void
    let onCancel: () -> Void

    init(firstName: String, lastName: String, email: String,
         title: String = "Create Account",
         subtitle: String = "Complete your profile to get started",
         accountType: UsersAccountType = .TEACHER,
         onAccountCreated: @escaping (GoogleUser) -> Void,
         onCancel: @escaping () -> Void) {
        _firstName = State(initialValue: firstName)
        _lastName = State(initialValue: lastName)
        _email = State(initialValue: email)
        self.title = title
        self.subtitle = subtitle
        self.accountType = accountType
        self.onAccountCreated = onAccountCreated
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 32, weight: .bold))

                        Text(subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)
                    
                    // Form fields
                    VStack(alignment: .leading, spacing: 16) {
                        // First Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.system(size: 16, weight: .medium))
                            
                            TextField("John", text: $firstName)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .disabled(createUserModel.isLoading)
                        }
                        
                        // Last Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(.system(size: 16, weight: .medium))
                            
                            TextField("Doe", text: $lastName)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .disabled(createUserModel.isLoading)
                        }
                        
                        // Email (read-only)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(email)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                                .foregroundColor(.secondary)
                        }
                        
                        // Error message
                        if let error = createUserModel.error {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                        
                        // Success message
                        if createUserModel.message != nil {
                            Text("Account created successfully!")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    // Create button
                    Button(action: {
                        Task {
                            await handleCreateAccount()
                        }
                    }) {
                        if createUserModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Text("Create Account")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(createUserModel.isLoading || !isFormValid())
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .disabled(createUserModel.isLoading)
                }
            }
        }
    }
    
    private func isFormValid() -> Bool {
        return !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
               !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
               !email.isEmpty
    }
    
    private func handleCreateAccount() async {
        await createUserModel.createUser(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            email: email,
            accountType: accountType
        )
        
        if createUserModel.message != nil && createUserModel.error == nil {
            // Wait a moment to show success message
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Create the GoogleUser and pass it back
            let createdUser = GoogleUser(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                email: email
            )
            onAccountCreated(createdUser)
        }
    }
}

#Preview {
    CreateAccountView(
        firstName: "FirstName",
        lastName: "LastName",
        email: "Email@email.com",
        onAccountCreated: { _ in },
        onCancel: {}
    )
}

