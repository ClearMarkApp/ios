//
//  SubmissionsTabView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

struct SubmissionsTabView: View {
    let assignmentInfo: AssignmentInfoResponseBody
    
    // Computed properties to split the users
    private var pendingUsers: [AssignmentInfoResponseBody.User] {
        assignmentInfo.usersById.values.filter { user in
            guard user.role == .STUDENT else { return false }
            let submission = assignmentInfo.submissionsByStudentId[user.id]
            let grade = assignmentInfo.gradesByStudentId[user.id]
            return grade == nil // If no grade exists, it's pending
        }.sorted { $0.lastName < $1.lastName }
    }
    
    private var gradedUsers: [AssignmentInfoResponseBody.User] {
        assignmentInfo.usersById.values.filter { user in
            assignmentInfo.gradesByStudentId[user.id] != nil
        }.sorted { $0.lastName < $1.lastName }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                Text("Submissions")
                    .fontWeight(.bold)
                    .font(.title)
                if !pendingUsers.isEmpty {
                    SectionView(title: "Pending", users: pendingUsers, assignmentInfo: assignmentInfo)
                }
                
                if !gradedUsers.isEmpty {
                    SectionView(title: "Graded", users: gradedUsers, assignmentInfo: assignmentInfo)
                }
            }
            .padding()
        }
    }
}

struct SectionView: View {
    let title: String
    let users: [AssignmentInfoResponseBody.User]
    let assignmentInfo: AssignmentInfoResponseBody
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            ForEach(users) { user in
                NavigationLink(destination: SubmissionAPIView(assignmentId: assignmentInfo.id, userId: user.id)) {
                    SubmissionUserCard(
                        user: user,
                        submission: assignmentInfo.submissionsByStudentId[user.id],
                        grade: assignmentInfo.gradesByStudentId[user.id],
                        totalMarks : assignmentInfo.totalAssignmentMarks
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct SubmissionUserCard: View {
    let user: AssignmentInfoResponseBody.User
    let submission: AssignmentInfoResponseBody.Submission?
    let grade: AssignmentInfoResponseBody.Grade?
    let totalMarks : Decimal
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.gradient)
                    .frame(width: 48, height: 48)
                Text("\(user.firstName.prefix(1))\(user.lastName.prefix(1))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.system(size: 17, weight: .semibold))
                
                // Status Label
                Group {
                    if let grade = grade {
                        let percentage = totalMarks != 0 ? (grade.score / totalMarks) * 100 : 0
                        Text("Score: \(percentage.formatted(.number.precision(.fractionLength(1))))%")
                            .foregroundColor(.green)
                    } else if let sub = submission {
                        Text(sub.status.rawValue.capitalized)
                            .foregroundColor(.orange)
                    } else {
                        Text("Not Submitted")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.subheadline)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    SubmissionsTabView(assignmentInfo: previewAssignmentInfo)
}
