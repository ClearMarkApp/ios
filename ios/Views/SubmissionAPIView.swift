//
//  SubmissionAPIView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct SubmissionAPIView: View {
    let assignmentId : Int
    let userId : Int
    @StateObject private var vm = UserSubmissionViewModel()
    
    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView()
            } else if let error = vm.error {
                Text("Error")
                Text(error)
                Button("Retry") {
                    Task {
                        await vm.fetchSubmissionInfo(assignmentId: assignmentId, userId : userId)
                    }
                }
            } else {
                UserSubmissionView(
                    userSubmissionInfo: vm.userSubmissionInfo ?? previewSubmissionData,
                    assignmentId: assignmentId,
                    userId: userId,
                    refetch: {
                        await vm.fetchSubmissionInfo(assignmentId: assignmentId, userId : userId)
                    }
                )
            }
        }
        .task {
            await vm.fetchSubmissionInfo(assignmentId: assignmentId, userId : userId)
        }
    }
}

#Preview {
    SubmissionAPIView(assignmentId : 1, userId : 4)
}
