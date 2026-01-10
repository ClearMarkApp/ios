//
//  CreateQuestionView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct CreateQuestionView: View {
    let assignmentId: Int
    @Environment(\.dismiss) private var dismiss
    @State private var questionNumber = ""
    @State private var questionText = ""
    @State private var maxPoints: Decimal = 0
    @State private var solutionKey = ""
    @StateObject private var createQuestionVM = CreateQuestionModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Create Question")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Question Number")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            TextField("Question number", text: $questionNumber)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Question Text")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            TextField("Enter question", text: $questionText, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                                .lineLimit(3...6)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Max Points")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            TextField("Points", value: $maxPoints, format: .number)
                                .textFieldStyle(.plain)
                                .keyboardType(.decimalPad)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Solution Key")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            TextField("Enter solution", text: $solutionKey, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                                .lineLimit(3...6)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Create") {
                    Task {
                        await createQuestionVM.createQuestion(
                            assignmentId: assignmentId,
                            questionNumber: questionNumber,
                            questionText: questionText,
                            maxPoints: maxPoints,
                            solutionKey: solutionKey
                        )
                        if createQuestionVM.error == nil {
                            dismiss()
                            // TODO: Refresh assignment data to show new question
                        }
                    }
                }
                .disabled(questionNumber.isEmpty || questionText.isEmpty)
            )
        }
    }
}

#Preview {
    CreateQuestionView(assignmentId: 1)
}
