//
//  CourseDetailView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct CourseDetailView: View {
    let courseId : Int
    @StateObject private var vm = CourseDetailViewModel()
    @State private var selectedTab = 0
    
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
                        
                        CourseSettingsView()
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
    var body: some View {
        VStack(spacing: 12) {
            Text("Settings")
                .font(.title2)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
    }
}

#Preview {
    CourseDetailView(courseId: 1)
}
