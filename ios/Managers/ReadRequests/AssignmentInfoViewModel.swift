//
//  AssignmentInfoViewModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class AssignmentInfoViewModel: ObservableObject {
    @Published var assignmentInfo: AssignmentInfoResponseBody?
    @Published var isLoading = false
    @Published var error: String?

    func fetchAssignmentInfo(assignmentId : Int) async {
        isLoading = true
        error = nil

        do {
            assignmentInfo = try await APIClient.shared.request(
                path: "/api/assignments/\(assignmentId)",
                method: .get,
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
