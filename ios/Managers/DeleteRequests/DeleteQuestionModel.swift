//
//  DeleteQuestionModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class DeleteQuestionModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?

    func deleteQuestion(questionId : Int) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/questions/\(questionId)",
                method: .delete,
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
