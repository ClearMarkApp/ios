//
//  ClassListCardView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

struct ClassListCardView: View {
    let course : ClassListResponseBody.Course
    var body: some View {
//        HStack(spacing: 20) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(course.uiColor)
//                    .frame(width: 44, height: 44)
//
//                Text(course.courseCode.coursePrefix)
//                    .font(.caption)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .lineLimit(1)
//            }
//
//            VStack(alignment: .leading) {
//                Text(course.courseName)
//                    .font(.headline)
//                    .fontWeight(.medium)
//                    .lineLimit(1)
//                    .truncationMode(.tail)
//                Text(course.courseCode)
//                    .foregroundColor(Color("Black2"))
//            }
//
//            Spacer()
//
//            HStack(spacing: 20) {
//                VStack(alignment: .trailing) {
//                    Text("\(course.headcount)")
//                    Text("Students")
//                        .foregroundColor(Color("Black2"))
//                }
//                Image(systemName: "chevron.right")
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(20)
//        .background(Color.white) // optional, to make the tap area visible
//        .cornerRadius(12)
//        .overlay(RoundedRectangle(cornerRadius: 12)
//            .stroke(Color("Black2").opacity(0.5), lineWidth: 1))
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(course.uiColor)
                .frame(height: 4)
            
            VStack(alignment: .leading, spacing: 12) {
                // Course code with colored dot
                HStack(spacing: 6) {
                    Circle()
                        .fill(course.uiColor)
                        .frame(width: 8, height: 8)
                    
                    Text(course.courseCode)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                
                // Course name
                Text(course.courseName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                    .frame(height: 8)
                
                // Bottom row with owner and headcount
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text(course.owner)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text("\(course.headcount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
    }
}
