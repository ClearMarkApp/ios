//
//  UpdateGradeModels.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class UpdateGradeModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    struct GradeRequestBody : Encodable {
        let gradeId : Int
        let grade : Decimal
        let feedback : String
    }

    func updateGrade(gradeId : Int, grade : Decimal, feedback : String) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/grades",
                method: .put,
                body: GradeRequestBody(gradeId : gradeId, grade : grade, feedback : feedback)
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
