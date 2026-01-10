//
//  CourseAssignmentsCardView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

struct CourseAssignmentsCardView: View {
    let assignment: CourseDetailResponseBody.Assignment
    
    private var isPending: Bool {
        assignment.numSubmitted != assignment.totalStudents
    }
    
    private var pendingCount: Int {
        assignment.totalStudents - assignment.numSubmitted
    }
    
    private var completionPercentage: Double {
        Double(assignment.numSubmitted) / Double(assignment.totalStudents)
    }
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            // Header with title and badge
            HStack(alignment: .top, spacing: 12) {
                Text(assignment.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isPending {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("\(pendingCount)")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Complete")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                }
            }
            
            // Due Date
            Text("Due \(assignment.dueDate, style: .date)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            // Progress Section
            VStack(alignment: .leading, spacing: 10) {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * completionPercentage, height: 6)
                    }
                }
                .frame(height: 6)
                
                // Stats Row
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text("\(assignment.numSubmitted) / \(assignment.totalStudents)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("submitted")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
    }
}
