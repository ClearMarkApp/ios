//
//  CreateAssignmentModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class CreateAssignmentModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    struct AssignmentRequestBody : Encodable {
        // gradinng guidelines should be empty on assignment creation
        let courseId : Int
        let title : String
        let submissionType : AssignmentsSubmissionType
        let dueDate : Date
        let gradingGuidelines : String = ""
    }

    func createAssignment(courseId : Int, title : String, submissionType : AssignmentsSubmissionType, dueDate : Date) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/assignments",
                method: .post,
                body: AssignmentRequestBody(courseId : courseId, title : title, submissionType : submissionType, dueDate: dueDate)
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
