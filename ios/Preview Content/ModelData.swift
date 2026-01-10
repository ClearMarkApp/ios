//
//  ModelData.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation


var previewClassList: ClassListResponseBody = load("classListData.json")
var previewCourseDetailData : CourseDetailResponseBody = load("courseDetailData.json")
var previewAssignmentInfo : AssignmentInfoResponseBody = load("assignmentInfoData.json")
var previewSubmissionData : UserSubmissionResponseBody = load("userSubmissionData.json")

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    } catch {
        print(error)
        fatalError("Decoding failed")
    }
}
