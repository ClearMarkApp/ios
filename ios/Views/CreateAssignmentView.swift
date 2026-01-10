//
//  CreateAssignmentView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct CreateAssignmentView: View {
    let courseId: Int
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = CreateAssignmentModel()
    
    @State private var title = ""
    @State private var submissionType: AssignmentsSubmissionType = .ADMIN_SCAN
    @State private var dueDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // default: 1 week from now
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Assignment Title", text: $title)
                        .disabled(vm.isLoading)
                } header: {
                    Text("Title")
                }
                
                Section {
                    Picker("Submission Type", selection: $submissionType) {
                        Text("Admin Scan").tag(AssignmentsSubmissionType.ADMIN_SCAN)
                        Text("Student Scan").tag(AssignmentsSubmissionType.STUDENT_SCAN)
                    }
                    .pickerStyle(.segmented)
                    .disabled(vm.isLoading)
                } header: {
                    Text("Submission Type")
                } footer: {
                    Text(submissionType == .ADMIN_SCAN
                         ? "Instructor collects and scans all submissions"
                         : "Students scan and upload their own submissions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .disabled(vm.isLoading)
                } header: {
                    Text("Due Date")
                }
            }
            .navigationTitle("New Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(vm.isLoading)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await vm.createAssignment(
                                courseId: courseId,
                                title: title.trimmingCharacters(in: .whitespaces),
                                submissionType: submissionType,
                                dueDate: dueDate
                            )
                            if vm.error == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        if vm.isLoading {
                            ProgressView()
                        } else {
                            Text("Create")
                        }
                    }
                    .disabled(!isFormValid || vm.isLoading)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { vm.error != nil },
                set: { if !$0 { vm.error = nil } }
            )) {
                Button("OK") {
                    vm.error = nil
                }
            } message: {
                if let error = vm.error {
                    Text(error)
                }
            }
        }
    }
}

#Preview {
    CreateAssignmentView(courseId: 1)
}
