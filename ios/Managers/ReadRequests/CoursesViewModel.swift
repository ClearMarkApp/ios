//
//  CoursesViewModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class CoursesViewModel: ObservableObject {
    @Published var classData: ClassListResponseBody?
    @Published var isLoading = false
    @Published var error: String?
    
    struct body : Encodable{
        let email : String
    }

    func fetchCourses(email : String) async {
        isLoading = true
        error = nil

        do {
            classData = try await APIClient.shared.request(
                path: "/api/users/classes",
                method: .post,
                body : body(email: email)
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
