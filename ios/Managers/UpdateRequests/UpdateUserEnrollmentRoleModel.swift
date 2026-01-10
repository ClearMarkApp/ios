//
//  UpdateUserEnrollmentRoleModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class UpdateUserEnrollmentRoleModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    struct EnrollmentRoleRequestBody : Encodable {
        let enrollmentId : Int
        let newRole : CourseEnrollmentsRole
    }

    func updateRole(enrollmentId : Int, newRole : CourseEnrollmentsRole) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/enrollments/role",
                method: .put,
                body: EnrollmentRoleRequestBody(enrollmentId : enrollmentId, newRole : newRole)
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
