//
//  CourseAssignmentsView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct CourseAssignmentsView: View {
    let courseId: Int
    let assignments: [CourseDetailResponseBody.Assignment]?
    @State private var showCreateAssignment = false
    
    var body: some View {
        if let assignments = assignments {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Assignments")
                        .fontWeight(.bold)
                        .font(.title)

                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(assignments, id: \CourseDetailResponseBody.Assignment.id) { (assignment: CourseDetailResponseBody.Assignment) in
                            NavigationLink(destination: AssignmentInfoView(assignmentId : assignment.id)) {
                                CourseAssignmentsCardView(assignment: assignment)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateAssignment = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $showCreateAssignment) {
                CreateAssignmentView(courseId: courseId)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CourseAssignmentsView(courseId: 1, assignments: previewCourseDetailData.assignments)
    }
}
