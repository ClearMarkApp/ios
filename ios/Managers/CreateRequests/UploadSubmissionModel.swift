//
//  UploadSubmissionModel.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import Foundation
import Combine

@MainActor
class UploadSubmissionModel: ObservableObject {
    @Published var message: GenericRequestResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    private let baseURL = "https://clearmark-4so0.onrender.com"
    private let apiKey = "nob"
    
    func uploadFile(fileURL: URL, userId: Int, assignmentId: Int) async {
        isLoading = true
        error = nil
        message = nil

        do {
            // Construct the URL path
            let path = "/api/users/\(userId)/assignments/\(assignmentId)/upload"
            guard let url = URL(string: baseURL + path) else {
                throw APIError(message: "Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            // Add the file
            let fileData = try Data(contentsOf: fileURL)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse,
                  200..<300 ~= http.statusCode else {
                throw APIError(message: "Upload failed")
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(GenericRequestResponse.self, from: data)
            message = result // Store the entire response object
            
            // Delete local file after successful upload
            try? FileManager.default.removeItem(at: fileURL)
            
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
