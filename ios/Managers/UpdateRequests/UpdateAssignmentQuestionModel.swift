//
//  UpdateAssignmentQuestionModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class UpdateAssignmentQuestionModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    struct AssignmentQuestionRequestBody : Encodable {
        let questionId : Int
        let questionNumber : String
        let questionText : String
        let maxPoints : Decimal
        let solutionKey : String
    }

    func updateQuestion(questionId : Int, questionNumber : String, questionText : String, maxPoints : Decimal, solutionKey : String) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/questions",
                method: .put,
                body: AssignmentQuestionRequestBody(questionId : questionId, questionNumber : questionNumber, questionText : questionText, maxPoints : maxPoints, solutionKey : solutionKey)
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
