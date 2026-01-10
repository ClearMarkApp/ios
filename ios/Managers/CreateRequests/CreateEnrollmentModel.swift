//
//  CreateEnrollmentModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class CreateEnrollmentModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    // create an enrollment for a person in a course (default role is STUDENT)
    struct EnrollmentRequestBody : Encodable {
        let role : CourseEnrollmentsRole = .STUDENT
        let email : String
        let courseId : Int
    }

    func createEnrollment(courseId: Int, email: String) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/enrollments",
                method: .post,
                body: EnrollmentRequestBody(email: email, courseId: courseId)
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
