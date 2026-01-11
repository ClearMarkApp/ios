//
//  AddPersonToCourseView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

struct AddPersonToCourseView: View {
    let courseId: Int
    let onUpdate: () async -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = CreateEnrollmentModel()
    @StateObject private var checkUserModel = CheckUserExistsModel()

    @State private var email = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showingCreateUserView = false

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && isValidEmail(email)
    }

    private var isBusy: Bool {
        isSubmitting || vm.isLoading || checkUserModel.isLoading
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("student@example.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(isBusy)
                        .onChange(of: email) { _, newValue in
                            // trim whitespace as user types
                            email = newValue.trimmingCharacters(in: .whitespaces)
                        }
                } header: {
                    Text("Email Address")
                } footer: {
                    if !email.isEmpty && !isValidEmail(email) {
                        Label("Please enter a valid email address", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Text("New enrollments are created with Student role. Role changes can be made after enrollment.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Role Information")
                }
            }
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isBusy)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await handleAdd()
                        }
                    } label: {
                        if isBusy {
                            ProgressView()
                        } else {
                            Text("Add")
                        }
                    }
                    .disabled(!isFormValid || isBusy)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { currentError != nil },
                set: { if !$0 { clearErrors() } }
            )) {
                Button("OK") {
                    clearErrors()
                }
            } message: {
                Text(currentError ?? "Unknown error")
            }
            .sheet(isPresented: $showingCreateUserView) {
                CreateAccountView(
                    firstName: "",
                    lastName: "",
                    email: email.trimmingCharacters(in: .whitespaces),
                    title: "Add Student",
                    subtitle: "Enter student information to add them to the course",
                    accountType: .STUDENT,
                    onAccountCreated: { user in
                        Task {
                            await handleUserCreated()
                        }
                    },
                    onCancel: {
                        showingCreateUserView = false
                    }
                )
            }
        }
    }

    @MainActor
    private func handleAdd() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard isValidEmail(trimmedEmail) else { return }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let exists = await checkUserModel.checkUserExists(email: trimmedEmail)

        // Check if there was an error during the user existence check
        if checkUserModel.error != nil {
            // Don't proceed if we couldn't verify user existence
            return
        }

        if exists {
            await vm.createEnrollment(courseId: courseId, email: trimmedEmail)
            if vm.error == nil {
                dismiss()
                await onUpdate()
            }
            return
        }

        // User doesn't exist, show create user view
        showingCreateUserView = true
    }

    @MainActor
    private func handleUserCreated() async {
        showingCreateUserView = false

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        // Now enroll the newly created user in the course
        await vm.createEnrollment(courseId: courseId, email: trimmedEmail)

        if vm.error == nil {
            dismiss()
            await onUpdate()
        }
    }

    private var currentError: String? {
        errorMessage ?? vm.error ?? checkUserModel.error
    }

    private func clearErrors() {
        errorMessage = nil
        vm.error = nil
        checkUserModel.error = nil
    }

    // helper: validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

}

#Preview {
    AddPersonToCourseView(courseId: 1, onUpdate: {})
}
