//
//  CreateUserModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class CreateUserModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    struct UserRequestBody : Encodable {
        let firstName : String
        let lastName : String
        let email : String
        let accountType : UsersAccountType
    }

    func createUser(firstName : String, lastName : String, email : String, accountType : UsersAccountType) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/users",
                method: .post,
                body: UserRequestBody(firstName: firstName, lastName: lastName, email: email, accountType: accountType)
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
