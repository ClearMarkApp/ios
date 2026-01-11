//
//  GetAssignmentCSVModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class GetAssignmentCSVModel: ObservableObject {
    @Published var csvData: Data?
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchCSV(assignmentId : Int) async {
        isLoading = true
        error = nil

        do {
            csvData = try await APIClient.shared.requestData(
                path: "/api/assignments/\(assignmentId)/export",
                method: .get
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
