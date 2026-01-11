//
//  CoursePeopleView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct CoursePeopleView: View {
    let courseId: Int
    let users: [CourseDetailResponseBody.User]?
    let onUserUpdated: () -> Void
    let onUpdate : () async -> Void
    @State private var showingAddPersonView = false
    @State private var selectedUser: CourseDetailResponseBody.User?
    
    private var groupedUsers: [(role: CourseEnrollmentsRole, users: [CourseDetailResponseBody.User])] {
        let roleOrder: [CourseEnrollmentsRole] = [.OWNER, .ADMIN, .STUDENT]
        let grouped = Dictionary(grouping: users ?? []) { $0.role }
        
        return roleOrder.compactMap { role in
            guard let roleUsers = grouped[role], !roleUsers.isEmpty else { return nil }
            return (role, roleUsers)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("People")
                    .fontWeight(.bold)
                    .font(.title)
                
                // Grouped User Lists
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(groupedUsers, id: \.role) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            // Section Header
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(group.role.color.opacity(0.15))
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: iconForRole(group.role))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(group.role.color)
                                }
                                
                                Text(group.role.displayName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                    .foregroundColor(.secondary)
                                
                                if group.users.count > 1 {
                                    Text("(\(group.users.count))")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // User Cards
                            VStack(spacing: 8) {
                                ForEach(group.users) { user in
                                    UserCardView(user: user, accentColor: group.role.color) {
                                        selectedUser = user
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddPersonView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPersonView) {
            AddPersonToCourseView(courseId: courseId, onUpdate : onUpdate)
        }
        .sheet(item: $selectedUser) { user in
            UserEnrollmentManagementView(user: user, courseId: courseId, onUserUpdated: onUserUpdated)
        }
        .refreshable {
            await onUpdate()
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

struct UserCardView: View {
    let user: CourseDetailResponseBody.User
    let accentColor: Color
    let onTap: () -> Void
    
    private var initials: String {
        "\(user.firstName.prefix(1))\(user.lastName.prefix(1))"
    }
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 14) {
                // Avatar Circle
                ZStack {
                    Circle()
                        .fill(accentColor.gradient)
                        .frame(width: 48, height: 48)
                    
                    Text(initials)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // User Name
                Text("\(user.firstName) \(user.lastName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        CoursePeopleView(courseId: 1, users: previewCourseDetailData.users, onUserUpdated: {}, onUpdate: {})
    }
}
