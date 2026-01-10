//
//  CreateCourseView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI

struct CreateCourseView: View {
    let email: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = CreateCourseModel()

    @State private var courseName = ""
    @State private var courseCode = ""
    @State private var color = Color.white

    private var isFormValid: Bool {
        !courseName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !courseCode.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func colorToHex(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Course Name", text: $courseName)
                        .disabled(vm.isLoading)
                } header: {
                    Text("Course Name")
                }

                Section {
                    TextField("Course Code", text: $courseCode)
                        .disabled(vm.isLoading)
                } header: {
                    Text("Course Code")
                }

                Section {
                    ColorPicker("Select Color", selection: $color)
                        .disabled(vm.isLoading)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle("New Course")
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
                            await vm.createCourse(
                                courseCode: courseCode.trimmingCharacters(in: .whitespaces),
                                courseName: courseName.trimmingCharacters(in: .whitespaces),
                                color: colorToHex(color),
                                email: email
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
    CreateCourseView(email: "john.teacher@school.com")
}
