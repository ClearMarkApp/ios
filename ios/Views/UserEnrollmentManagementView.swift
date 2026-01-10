//
//  UserEnrollmentManagementView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

struct UserEnrollmentManagementView: View {
    let user: CourseDetailResponseBody.User
    let courseId: Int
    let onUserUpdated: () -> Void
    @StateObject private var updateModel = UpdateUserEnrollmentRoleModel()
    @StateObject private var deleteModel = DeleteEnrollmentModel()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedRole: CourseEnrollmentsRole
    @State private var showingDeleteAlert = false

    init(user: CourseDetailResponseBody.User, courseId: Int, onUserUpdated: @escaping () -> Void) {
        self.user = user
        self.courseId = courseId
        self.onUserUpdated = onUserUpdated
        _selectedRole = State(initialValue: user.role)
    }

    private var initials: String {
        "\(user.firstName.prefix(1))\(user.lastName.prefix(1))"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // User Info Section
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(user.role.color.gradient)
                            .frame(width: 80, height: 80)

                        Text(initials)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(spacing: 4) {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.primary)

                        Text(user.email)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 32)

                // Role Selection Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Role")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    VStack(spacing: 0) {
                        ForEach([CourseEnrollmentsRole.ADMIN, .STUDENT], id: \.self) { role in
                            Button(action: {
                                selectedRole = role
                            }) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(role.color.opacity(0.15))
                                            .frame(width: 32, height: 32)

                                        Image(systemName: iconForRole(role))
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(role.color)
                                    }

                                    Text(role.displayName)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    if selectedRole == role {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(.systemBackground))
                            }
                            .buttonStyle(PlainButtonStyle())

                            if role != .STUDENT {
                                Divider()
                                    .padding(.leading, 58)
                            }
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                }
                .padding(.horizontal)

                // Update Button
                if selectedRole != user.role {
                    Button(action: {
                        Task {
                            await updateModel.updateRole(enrollmentId: user.enrollmentId, newRole: selectedRole)
                            if updateModel.error == nil {
                                onUserUpdated()
                                dismiss()
                            }
                        }
                    }) {
                        if updateModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Update Role")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(updateModel.isLoading)
                }

                Spacer()

                // Delete Button
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Text("Remove from Course")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.bottom, 32)
                .disabled(updateModel.isLoading || deleteModel.isLoading)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Manage User")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .alert("Remove User", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    Task {
                        await deleteModel.deleteEnrollment(enrollmentId: user.enrollmentId)
                        if deleteModel.error == nil {
                            onUserUpdated()
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to remove \(user.firstName) \(user.lastName) from this course? This action cannot be undone.")
            }
            .alert("Error", isPresented: .constant(updateModel.error != nil || deleteModel.error != nil)) {
                Button("OK") {
                    updateModel.error = nil
                    deleteModel.error = nil
                }
            } message: {
                Text(updateModel.error ?? deleteModel.error ?? "Unknown error")
            }
        }
    }

    private func iconForRole(_ role: CourseEnrollmentsRole) -> String {
        switch role {
        case .OWNER: return "crown.fill"
        case .ADMIN: return "star.fill"
        case .STUDENT: return "person.fill"
        }
    }
}

#Preview {
    UserEnrollmentManagementView(user: previewCourseDetailData.users[0], courseId: 1, onUserUpdated: {})
}
