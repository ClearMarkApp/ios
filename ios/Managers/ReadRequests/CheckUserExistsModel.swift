//
//  CheckUserExistsModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class CheckUserExistsModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: String?

    func checkUserExists(email: String) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }

        struct CheckUserExistsResponse: Decodable {
            let exists: Bool
        }

        do {
            let response: CheckUserExistsResponse = try await APIClient.shared.request(
                path: "/api/users/check-exists/\(email)",
                method: .get,
                body: nil as String? // No body needed for GET
            )
            // Return the actual exists value from the backend
            return response.exists
        } catch {
            // If there's an error (network, parsing, etc.), assume user doesn't exist
            return false
        }
    }
}
