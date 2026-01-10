//
//  CreateCourseModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class CreateCourseModel: ObservableObject {
    @Published var message : GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    // create a course and an enrollment for the creator
    struct CourseRequestBody : Encodable {
        // create course
        let courseCode : String
        let courseName : String
        let color : String
        
        // create enrollment - grab the course id after the course is created on backend
        let email : String
        let role : CourseEnrollmentsRole = .OWNER
    }

    func createCourse(courseCode : String, courseName : String, color : String, email : String) async {
        isLoading = true
        error = nil

        do {
            message = try await APIClient.shared.request(
                path: "/api/courses",
                method: .post,
                body: CourseRequestBody(courseCode : courseCode, courseName : courseName, color : color, email : email)
            )
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
