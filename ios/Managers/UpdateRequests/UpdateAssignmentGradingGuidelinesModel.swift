//
//  UpdateAssignmentGradingGuidelinesModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class UpdateAssignmentGradingGuidelinesModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    struct AssignmentGradingGuidelinesRequestBody : Encodable {
        let assignmentId : Int
        let gradingGuidelines : String
    }

    func updateGradingGuideline(assignmentId : Int, gradingGuidelines : String) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/assignments/grading-guidelines",
                method: .put,
                body: AssignmentGradingGuidelinesRequestBody(assignmentId : assignmentId, gradingGuidelines : gradingGuidelines)
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
