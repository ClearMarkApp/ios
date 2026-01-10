//
//  SolutionsTabView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

struct SolutionsTabView: View {
    @State var assignmentInfo: AssignmentInfoResponseBody
    @Binding var showingCreateQuestion: Bool
    @State private var isEditingGuidelines = false
    @State private var editedGuidelines: String = ""
    @State private var editMode: EditMode = .inactive
    @StateObject private var vm = UpdateAssignmentGradingGuidelinesModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Solutions")
                    .fontWeight(.bold)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Section Header
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "list.clipboard.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                        Text("Grading Guidelines")
                            .font(.system(size: 13, weight: .semibold))
                            .textCase(.uppercase)
                            .tracking(0.5)
                            .foregroundColor(.secondary)
                    }
                    
                    // Guidelines Card
                    VStack(alignment: .leading, spacing: 12) {
                        if isEditingGuidelines {
                            TextEditor(text: $editedGuidelines)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            
                            Button(action: {
                                // Update logic here
                                isEditingGuidelines = false
                                Task {
                                    await vm.updateGradingGuideline(
                                        assignmentId: assignmentInfo.id,
                                        gradingGuidelines: editedGuidelines
                                    )
                                    
                                    // optimisitically update
                                    assignmentInfo.gradingGuidelines = editedGuidelines
                                }
                                
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Save")
                                        .font(.system(size: 16, weight: .semibold))
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        } else {
                            Text(assignmentInfo.gradingGuidelines)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                            
                            Button(action: {
                                editedGuidelines = assignmentInfo.gradingGuidelines
                                isEditingGuidelines = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Edit Guidelines")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Section Header
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.green)
                        }
                        
                        Text("Questions")
                            .font(.system(size: 13, weight: .semibold))
                            .textCase(.uppercase)
                            .tracking(0.5)
                            .foregroundColor(.secondary)
                        
                        Text("(\(assignmentInfo.questions.count))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Spacer()

                        Button(action: {
                            showingCreateQuestion = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Add")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(.blue)
                        }

                        Button(action: {
                            withAnimation {
                                editMode = editMode == .active ? .inactive : .active
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: editMode == .active ? "checkmark.circle.fill" : "arrow.up.arrow.down.circle")
                                    .font(.system(size: 14, weight: .medium))
                                Text(editMode == .active ? "Done" : "Reorder")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // Question Cards
                    if editMode == .active {
                        List {
                            ForEach($assignmentInfo.questions) { $question in
                                QuestionBlock(
                                    question: $question,
                                    isReorderMode: true
                                )
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .onMove { from, to in
                                assignmentInfo.questions.move(fromOffsets: from, toOffset: to)
                            }
                        }
                        .listStyle(.plain)
                        .frame(height: CGFloat(assignmentInfo.questions.count) * 300)
                        .scrollDisabled(true)
                    } else {
                        VStack(spacing: 8) {
                            ForEach($assignmentInfo.questions) { $question in
                                QuestionBlock(
                                    question: $question,
                                    isReorderMode: false
                                )
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .environment(\.editMode, $editMode)
    }
}

struct QuestionBlock: View {
    @Binding var question: AssignmentInfoResponseBody.Question
    @State private var isEditing = false
    var isReorderMode: Bool
    @StateObject private var vm2 = UpdateAssignmentQuestionModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with question number and badge
            HStack(alignment: .top, spacing: 12) {
                Text("Question \(question.questionNumber)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .medium))
                    Text("\(question.maxPoints.description)")
                        .font(.system(size: 14, weight: .medium))
                    Text("pts")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green)
                .clipShape(Capsule())
            }
            
            if isEditing {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Question Number")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("Question number", text: $question.questionNumber)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Question Text")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("Enter question", text: $question.questionText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Solution Key")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("Enter solution", text: $question.solutionKey, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Max Points")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("Points", value: $question.maxPoints, format: .number)
                            .textFieldStyle(.plain)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    Button(role: .destructive, action: {
                        // Functionality to be added later
                        print("Delete question tapped")
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Delete")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1)) // Light red background
                        .foregroundColor(.red)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        isEditing = false
                        
                        Task {
                            await vm2.updateQuestion(questionId: question.id, questionNumber: question.questionNumber, questionText: question.questionText, maxPoints: question.maxPoints, solutionKey: question.solutionKey)
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text(question.questionText)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("Solution Key")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(question.solutionKey)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isEditing = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Edit")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .padding(.trailing, isReorderMode ? 30 : 0)
    }
}

#Preview {
    SolutionsTabView(assignmentInfo: previewAssignmentInfo, showingCreateQuestion: .constant(false))
}
