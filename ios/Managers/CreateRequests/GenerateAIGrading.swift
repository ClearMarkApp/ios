//
//  GenerateAIGrading.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class GenerateAIGrading: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isSuccess = false
    
    // find all questions related to assignment and use the submission associated with user id
    // if no submission present for the user, then dont do anything
    func runAIGrading(assignmentId : Int, userId : Int) async {
        isLoading = true
        error = nil
        isSuccess = false

        do {
            message = try await APIClient.shared.request(
                path: "/api/assignments/\(assignmentId)/user/\(userId)/ai-grading",
                method: .get,
            )
            isSuccess = true
        } catch {
            self.error = error.localizedDescription
            isSuccess = false
        }

        isLoading = false
    }
    
    func reset() {
        message = nil
        error = nil
        isSuccess = false
        isLoading = false
    }
}
