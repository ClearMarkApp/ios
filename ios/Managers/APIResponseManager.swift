//
//  APIResponseManager.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

// These API calls for each view only require the info specific for that view and not anything more


enum UsersAccountType : String, Decodable, Encodable {
    case TEACHER, STUDENT
}

enum CourseEnrollmentsRole : String, Decodable, Encodable{
    case OWNER, ADMIN, STUDENT
    
    var displayName: String {
        switch self {
        case .OWNER: return "Owner"
        case .ADMIN: return "Admins"
        case .STUDENT: return "Students"
        }
    }
    
    var color: Color {
        switch self {
        case .OWNER: return .purple
        case .ADMIN: return .green
        case .STUDENT: return .blue
        }
    }
}

enum SubmissionStatus : String, Decodable{
    case SUBMITTED, GRADED, ERROR
}

enum AssignmentsSubmissionType : String, Decodable, Encodable{
    case ADMIN_SCAN, STUDENT_SCAN
}


// Response for ClassListView API call
// get all courses for a specific user
struct ClassListResponseBody:  Decodable {
    // required fields
    var classes : [Course]
    
    struct Course : Identifiable, Decodable {
        // required fields
        var id : Int
        var color : String
        var courseName : String
        var courseCode : String
        var headcount : Int32 // add this into the backend by counting the number of users in the class
        var owner : String
        
        // run time variables
        var uiColor: Color {
            Color(hex: color) // assumes Color extension for hex exists
        }
    }
}

// Response for CourseDetailView
// get all info for a course id
struct CourseDetailResponseBody : Decodable {
    // required fields
    var courseName : String
    var courseCode : String
    var color : String
    
    var assignments : [Assignment]
    var users : [User]

    struct Assignment : Identifiable, Decodable {
        var id : Int
        var title : String
        var submissionType : AssignmentsSubmissionType
        var dueDate : Date
        var createdAt : Date
        var numSubmitted : Int
        var totalStudents : Int
    }
    
    struct User : Identifiable, Decodable {
        var id : Int
        var firstName : String
        var lastName : String
        var email: String
        var role : CourseEnrollmentsRole
        var enrollmentId : Int
    }
}

// Response for AssignmentInfoView
struct AssignmentInfoResponseBody : Decodable {
    // required fields
    var id: Int
    var title : String
    var submissionType : AssignmentsSubmissionType
    var dueDate : Date
    var gradingGuidelines : String
    var totalAssignmentMarks : Decimal
    
    var questions : [Question]
    
    // backend send dictionaries
    let usersById: [Int: User]
    let submissionsByStudentId: [Int: Submission]
    let gradesByStudentId: [Int: Grade]
    
    struct Question : Identifiable, Decodable {
        var id : Int
        var questionNumber : String
        var questionText : String
        var maxPoints : Decimal
        var solutionKey : String
    }
    
    // submissions only apply for users with CourseEnrollmentRole STUDENT
    struct Submission : Identifiable, Decodable {
        var id : Int
        var status : SubmissionStatus
    }
    
    struct User : Identifiable, Decodable {
        var id : Int
        var firstName : String
        var lastName : String
        var email: String
        var role : CourseEnrollmentsRole
    }
    
    struct Grade : Identifiable, Decodable {
        var id : Int
        var score : Decimal // this field should contain total score from all quetsions graded summed
    }
}


// resposne for assigmnet view for a particular user
struct UserSubmissionResponseBody : Decodable {
    var user : User
    var submission : Submission? // may be null if nothing is submitted
    var grades : [Grade]
    
    struct User : Decodable {
        var firstName : String
        var lastName : String
        var email : String
    }
    
    struct Submission : Decodable {
        var imageUrl : String
        var status : SubmissionStatus
    }
    
    struct Grade : Identifiable, Decodable {
        var id : Int
        var grade : Decimal
        var feedback : String
        var maxPoints : Decimal
        var questionNumber : String
        var questionText : String
    }
}
