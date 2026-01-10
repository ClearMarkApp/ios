//
//  AssignmentInfoView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct AssignmentInfoView: View {
    let assignmentId: Int
    @State private var selectedTab = 0
    @State private var showingCreateQuestion = false
    @StateObject private var vm = AssignmentInfoViewModel()
    
    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
            } else if let error = vm.error {
                Text("Error")
                Text(error)
                Button("Retry") {
                    Task {
                        await vm.fetchAssignmentInfo(assignmentId: assignmentId)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("Submissions").tag(0)
                        Text("Solution").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        SubmissionsTabView(assignmentInfo: vm.assignmentInfo ?? previewAssignmentInfo)
                            .tag(0)
                        
                        SolutionsTabView(assignmentInfo: vm.assignmentInfo ?? previewAssignmentInfo, showingCreateQuestion: $showingCreateQuestion)
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .background(Color(.systemBackground))
                .navigationTitle(vm.assignmentInfo?.title ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .task {
            await vm.fetchAssignmentInfo(assignmentId: assignmentId)
        }
        .sheet(isPresented: $showingCreateQuestion) {
            CreateQuestionView(assignmentId: assignmentId)
        }
    }

}

#Preview {
    NavigationView {
        AssignmentInfoView(assignmentId: 1)
    }
}
