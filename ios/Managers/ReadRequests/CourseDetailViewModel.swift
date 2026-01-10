//
//  CourseDetailViewModel.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class CourseDetailViewModel: ObservableObject {
    @Published var courseDetail: CourseDetailResponseBody?
    @Published var isLoading = false
    @Published var error: String?

    func fetchCourseDetail(courseId : Int) async {
        isLoading = true
        error = nil

        do {
            courseDetail = try await APIClient.shared.request(
                path: "/api/courses/\(courseId)",
                method: .get,
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
