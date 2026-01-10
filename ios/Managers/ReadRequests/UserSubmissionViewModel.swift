//
//  UserSubmissionViewModel.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class UserSubmissionViewModel: ObservableObject {
    @Published var userSubmissionInfo: UserSubmissionResponseBody?
    @Published var isLoading = false
    @Published var error: String?

    func fetchSubmissionInfo(assignmentId : Int, userId : Int) async {
        isLoading = true
        error = nil

        do {
            userSubmissionInfo = try await APIClient.shared.request(
                path: "/api/assignments/\(assignmentId)/students/\(userId)/submission",
                method: .get,
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
