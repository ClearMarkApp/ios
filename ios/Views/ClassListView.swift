//
//  ClassListView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct ClassListView: View {
    let email : String
    let classData : ClassListResponseBody?
    let onRefresh: () async -> Void
    @State private var showCreateCourse = false

    var body: some View {
        if let classData = classData {
            let classes: [ClassListResponseBody.Course] = classData.classes
            let numClasses = classes.count
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Courses (\(numClasses))")
                        .fontWeight(.bold)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 24) {
                        ForEach(classes, id: \ClassListResponseBody.Course.id) { (course: ClassListResponseBody.Course) in
                            NavigationLink(destination: CourseDetailView(courseId: course.id)) {
                                ClassListCardView(course : course)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateCourse = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $showCreateCourse) {
                CreateCourseView(email: email) // TODO: Get actual user ID from authentication
            }
            .refreshable {
                await onRefresh()
            }
        } else {
            Text("Could not get class data")
        }
    }
    
    private func onCourseTap(_ course: ClassListResponseBody.Course) {
        // TODO: Hook up navigation or actions later
    }
}

#Preview {
    NavigationStack {
        ClassListView(email: "john.teacher@school.com", classData: previewClassList, onRefresh: {})
    }
}
