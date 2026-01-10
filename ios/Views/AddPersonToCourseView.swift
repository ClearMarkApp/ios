//
//  AddPersonToCourseView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

struct AddPersonToCourseView: View {
    let courseId: Int
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = CreateEnrollmentModel()

    @State private var email = ""

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && isValidEmail(email)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("student@example.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(vm.isLoading)
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
                    .disabled(vm.isLoading)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await vm.createEnrollment(
                                courseId: courseId,
                                email: email.trimmingCharacters(in: .whitespaces)
                            )
                            if vm.error == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        if vm.isLoading {
                            ProgressView()
                        } else {
                            Text("Add")
                        }
                    }
                    .disabled(!isFormValid || vm.isLoading)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { vm.error != nil },
                set: { if !$0 { vm.error = nil } }
            )) {
                Button("OK") {
                    vm.error = nil
                }
            } message: {
                if let error = vm.error {
                    Text(error)
                }
            }
        }
    }

    // helper: validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

}

#Preview {
    AddPersonToCourseView(courseId: 1)
}
