import SwiftUI
import PhotosUI
import PDFKit

struct UserSubmissionView: View {
    var userSubmissionInfo : UserSubmissionResponseBody
    var assignmentId: Int
    var userId: Int
    let refetch: () async -> Void
    
    @StateObject private var aiGrading = GenerateAIGrading()
    @StateObject private var vm = UploadSubmissionModel()
    @State private var editingGradeId: Int? = nil
    @State private var editedGrades: [Int: Decimal] = [:]
    @State private var editedFeedback: [Int: String] = [:]
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingDocumentPicker = false
    @State private var showingDocumentScanner = false
    @State private var scannedPDFURL: URL?
    @State private var isPDFZoomed = false
    
    var totalScore: Decimal {
        userSubmissionInfo.grades.reduce(0) { $0 + $1.grade }
    }
    
    var totalMaxPoints: Decimal {
        userSubmissionInfo.grades.reduce(0) { $0 + $1.maxPoints }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.15))
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.purple)
                            }
                            
                            Text("Student Information")
                                .font(.system(size: 13, weight: .semibold))
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(userSubmissionInfo.user.firstName) \(userSubmissionInfo.user.lastName)")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(userSubmissionInfo.user.email)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            
                            Text("Submission")
                                .font(.system(size: 13, weight: .semibold))
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 14) {
                            if let submission = userSubmissionInfo.submission {
                                Button(action: {
                                    isPDFZoomed = true
                                }) {
                                    PDFThumbnailView(url: URL(string: submission.imageUrl)!)
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(12)
                                        .overlay(
                                            ZStack {
                                                Color.black.opacity(0.3)
                                                VStack(spacing: 6) {
                                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                        .font(.system(size: 20, weight: .medium))
                                                        .foregroundColor(.white)
                                                    Text("Tap to expand")
                                                        .font(.system(size: 13, weight: .medium))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .cornerRadius(12)
                                            .opacity(0.8)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                HStack(spacing: 6) {
                                    Image(systemName: statusIcon(for: submission.status))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                    Text(submission.status.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(statusColor(for: submission.status))
                                .clipShape(Capsule())
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.system(size: 40, weight: .light))
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text("Nothing uploaded")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 40)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    showingDocumentScanner = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "doc.text.viewfinder")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Scan")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    showingDocumentPicker = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.up.doc")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Upload")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
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
                    
                    // ai grading button
                    Button(action: {
                        Task {
                            await aiGrading.runAIGrading(
                                assignmentId: assignmentId,
                                userId: userId
                            )
                            
                            // Refetch data after successful AI grading
                            if aiGrading.isSuccess {
                                await refetch()
                                // Reset the AI grading state after a brief delay
                                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                                aiGrading.reset()
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Grade with AI")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.9),
                                    Color.blue.opacity(0.8),
                                    Color.cyan.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.purple.opacity(0.4), radius: 12, x: 0, y: 6)
                        .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(aiGrading.isLoading)
                    .opacity(aiGrading.isLoading ? 0.6 : 1.0)
                    .padding(.horizontal)
                    
                    // Error message
                    if let error = aiGrading.error {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                    // Success message
                    if aiGrading.isSuccess && aiGrading.message != nil {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            Text(aiGrading.message?.message ?? "Grading completed!")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                    if !userSubmissionInfo.grades.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.15))
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.orange)
                                }
                                
                                Text("Grading Breakdown")
                                    .font(.system(size: 13, weight: .semibold))
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10, weight: .medium))
                                    Text("\(totalScore.formatted())")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("/ \(totalMaxPoints.formatted())")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .clipShape(Capsule())
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(userSubmissionInfo.grades) { grade in
                                    GradeCardView(
                                        grade: grade,
                                        editedGrade: Binding(
                                            get: { editedGrades[grade.id] ?? grade.grade },
                                            set: { editedGrades[grade.id] = $0 }
                                        ),
                                        editedFeedback: Binding(
                                            get: { editedFeedback[grade.id] ?? grade.feedback },
                                            set: { editedFeedback[grade.id] = $0 }
                                        ),
                                        onEdit: {
                                            if editingGradeId == grade.id {
                                                editingGradeId = nil
                                            } else {
                                                editingGradeId = grade.id
                                                editedGrades[grade.id] = grade.grade
                                                editedFeedback[grade.id] = grade.feedback
                                            }
                                        }
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
            
            // Loading overlay - OUTSIDE ScrollView, INSIDE ZStack
            if aiGrading.isLoading {
                AIGradingLoadingView()
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .navigationTitle("Submission Review")
        .navigationBarTitleDisplayMode(.inline)
//        .animation(.easeInOut(duration: 0.3), value: aiGrading.isLoading)
//        .animation(.easeInOut(duration: 0.3), value: aiGrading.error)
//        .animation(.easeInOut(duration: 0.3), value: aiGrading.isSuccess)
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(onDocumentPicked: { url in
                print("PDF selected: \(url)")
                Task {
                    await vm.uploadFile(fileURL: url, userId: userId, assignmentId: assignmentId)
                }
                print("allegedly sent")
            })
        }
        .sheet(isPresented: $showingDocumentScanner) {
            DocumentScannerView(isPresented: $showingDocumentScanner) { pdfURL in
                scannedPDFURL = pdfURL
                print("PDF scanned and saved at: \(pdfURL.path)")
                Task {
                    await vm.uploadFile(fileURL: pdfURL, userId: userId, assignmentId: assignmentId)
                }
                print("allegedly sent")
            }
        }
        .fullScreenCover(isPresented: $isPDFZoomed) {
            if let submission = userSubmissionInfo.submission {
                PDFViewerView(pdfUrl: submission.imageUrl, isPresented: $isPDFZoomed)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func statusIcon(for status: SubmissionStatus) -> String {
        switch status {
        case .SUBMITTED:
            return "checkmark.circle.fill"
        case .GRADED:
            return "checkmark.seal.fill"
        case .ERROR:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private func statusColor(for status: SubmissionStatus) -> Color {
        switch status {
        case .SUBMITTED:
            return .blue
        case .GRADED:
            return .green
        case .ERROR:
            return .red
        }
    }
}

// PDF Thumbnail View for Preview
struct PDFThumbnailView: View {
    let url: URL
    @State private var thumbnail: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.blue)
                    Text("PDF Document")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(.systemGray6))
        .onAppear {
            loadPDFThumbnail()
        }
    }
    
    private func loadPDFThumbnail() {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let pdfDocument = PDFDocument(data: data),
                   let firstPage = pdfDocument.page(at: 0) {
                    let pageRect = firstPage.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                    let img = renderer.image { ctx in
                        UIColor.white.set()
                        ctx.fill(pageRect)
                        ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                        firstPage.draw(with: .mediaBox, to: ctx.cgContext)
                    }
                    await MainActor.run {
                        thumbnail = img
                        isLoading = false
                    }
                }
            } catch {
                print("Error loading PDF thumbnail: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// Full PDF Viewer
struct PDFViewerView: View {
    let pdfUrl: String
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .background(Color.black.opacity(0.5))
                
                if let url = URL(string: pdfUrl) {
                    PDFKitView(url: url)
                } else {
                    Text("Invalid PDF URL")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// PDFKit UIViewRepresentable
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        // Download and load PDF
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let document = PDFDocument(data: data) {
                    await MainActor.run {
                        pdfView.document = document
                    }
                }
            } catch {
                print("Error loading PDF: \(error)")
            }
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct GradeCardView: View {
    @State var grade: UserSubmissionResponseBody.Grade
    @State var isEditing: Bool = false
    @Binding var editedGrade: Decimal
    @Binding var editedFeedback: String
    @StateObject private var vm = UpdateGradeModel()
    
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Text("Question \(grade.questionNumber)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isEditing {
                    HStack(spacing: 4) {
                        TextField("", value: $editedGrade, format: .number)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .frame(width: 40)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        Text("/ \(grade.maxPoints.formatted())")
                            .font(.system(size: 14, weight: .medium))
                        Text("pts")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.blue)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .medium))
                        Text("\(grade.grade.formatted())")
                            .font(.system(size: 14, weight: .medium))
                        Text("/ \(grade.maxPoints.formatted())")
                            .font(.system(size: 12, weight: .medium))
                        Text("pts")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(gradeColor(for: grade.grade, max: grade.maxPoints))
                    .clipShape(Capsule())
                }
            }
            
            if isEditing {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(grade.questionText)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Feedback")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        TextEditor(text: $editedFeedback)
                            .frame(minHeight: 80)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isEditing = false
                        Task {
                            await vm.updateGrade(gradeId: grade.id, grade: editedGrade, feedback: editedFeedback)
                        }
                        grade.feedback = editedFeedback
                        grade.grade = editedGrade
                    }) {
                        HStack {
                            Spacer()
                            Text("Save Changes")
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
                    Text(grade.questionText)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .lineSpacing(2)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("Feedback")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(grade.feedback)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .lineSpacing(2)
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
    }
    
    private func gradeColor(for grade: Decimal, max: Decimal) -> Color {
        let percentage = Double(truncating: grade as NSNumber) / Double(truncating: max as NSNumber)
        if percentage >= 0.8 {
            return .green
        } else if percentage >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Couldn't access security-scoped resource")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Copy file to app's temporary directory
            let tempDir = FileManager.default.temporaryDirectory
            let tempURL = tempDir.appendingPathComponent(url.lastPathComponent)
            
            do {
                // Remove existing file if it exists
                try? FileManager.default.removeItem(at: tempURL)
                
                // Copy the file
                try FileManager.default.copyItem(at: url, to: tempURL)
                
                // Pass the copied file URL
                parent.onDocumentPicked(tempURL)
            } catch {
                print("Error copying file: \(error)")
            }
        }
    }
}

#Preview {
    NavigationView {
        UserSubmissionView(userSubmissionInfo: previewSubmissionData, assignmentId: 1, userId: 1, refetch: {})
    }
}
