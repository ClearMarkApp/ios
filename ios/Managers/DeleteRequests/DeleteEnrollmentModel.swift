//
//  DeleteEnrollmentModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class DeleteEnrollmentModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?

    func deleteEnrollment(enrollmentId : Int) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/enrollments/\(enrollmentId)",
                method: .delete,
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
