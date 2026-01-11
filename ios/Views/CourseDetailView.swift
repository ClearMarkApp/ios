//
//  CourseDetailView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct CourseDetailView: View {
    let courseId : Int
    let onCourseDeleted: (() -> Void)?
    @StateObject private var vm = CourseDetailViewModel()
    @State private var selectedTab = 0

    init(courseId: Int, onCourseDeleted: (() -> Void)? = nil) {
        self.courseId = courseId
        self.onCourseDeleted = onCourseDeleted
    }
    
    var body: some View {
        
        Group {
            if vm.isLoading {
                ProgressView()
            } else if let error = vm.error {
                Text("Error")
                Text(error)
                Button("Retry") {
                    Task {
                        await vm.fetchCourseDetail(courseId: courseId)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    // Custom segmented control
                    Picker("", selection: $selectedTab) {
                        Text("Assignments").tag(0)
                        Text("People").tag(1)
                        Text("Settings").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        CourseAssignmentsView(courseId: courseId, assignments: vm.courseDetail?.assignments, onUpdate: {
                            Task {
                                await vm.fetchCourseDetail(courseId: courseId)
                            }
                        })
                            .tag(0)
                        
                        CoursePeopleView(courseId: courseId, users: vm.courseDetail?.users, onUserUpdated: {
                            Task {
                                await vm.fetchCourseDetail(courseId: courseId)
                            }
                        },
                            onUpdate : {
                            Task {
                                await vm.fetchCourseDetail(courseId: courseId)
                            }
                        })
                            .tag(1)
                        
                        CourseSettingsView(courseId: courseId, onCourseDeleted: onCourseDeleted)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .navigationTitle(vm.courseDetail?.courseCode ?? "")
                .navigationBarTitleDisplayMode(.inline)
        //        .toolbar(.hidden, for: .tabBar)
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .task {
            await vm.fetchCourseDetail(courseId: courseId)
        }
        
    }
}

struct CourseSettingsView: View {
    let courseId: Int
    let onCourseDeleted: (() -> Void)?
    @StateObject private var deleteModel = DeleteCourseModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false

    var body: some View {
        VStack(spacing: 12) {
            Text("Settings")
                .font(.title2)

            Spacer()

            // Delete Button
            Button(action: {
                showingDeleteAlert = true
            }) {
                Text("Delete Course")
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
            .disabled(deleteModel.isLoading)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .alert("Delete Course", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await deleteModel.deleteCourse(courseId: courseId)
                    if deleteModel.error == nil {
                        onCourseDeleted?()
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this course? This action cannot be undone and will remove all assignments, submissions, and enrollments.")
        }
        .alert("Error", isPresented: .constant(deleteModel.error != nil)) {
            Button("OK") {
                deleteModel.error = nil
            }
        } message: {
            Text(deleteModel.error ?? "Unknown error")
        }
    }
}

#Preview {
    CourseDetailView(courseId: 1)
}
