//
//  DocumentScannerView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI
import VisionKit
import PDFKit
import UIKit

struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onDocumentScanned: (URL) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // Process all scanned pages
            var processedImages: [UIImage] = []
            
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                // Apply image processing to enhance handwritten text
                if let processedImage = enhanceDocumentImage(image) {
                    print("✅ Successfully applied B&W filter to page \(pageIndex + 1)")
                    processedImages.append(processedImage)
                } else {
                    print("⚠️ Failed to apply filter to page \(pageIndex + 1), using original")
                    processedImages.append(image)
                }
            }
            
            // Create PDF from processed images
            if let pdfURL = createPDF(from: processedImages) {
                parent.onDocumentScanned(pdfURL)
            }
            
            parent.isPresented = false
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.isPresented = false
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document scanning failed: \(error.localizedDescription)")
            parent.isPresented = false
        }
        
        // MARK: - Image Processing
        
        /// Enhances document image with contrast enhancement and binarization
        /// Applies aggressive black and white filter for clear document scanning
        private func enhanceDocumentImage(_ image: UIImage) -> UIImage? {
            guard let ciImage = CIImage(image: image) else { return nil }
            
            let context = CIContext()
            
            // Step 1: Convert to grayscale (strong B&W conversion)
            guard let grayscaleFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
            grayscaleFilter.setValue(ciImage, forKey: kCIInputImageKey)
            guard let grayscaleOutput = grayscaleFilter.outputImage else { return nil }
            
            // Step 2: Enhance contrast significantly for B&W effect
            guard let contrastFilter = CIFilter(name: "CIColorControls") else { return nil }
            contrastFilter.setValue(grayscaleOutput, forKey: kCIInputImageKey)
            contrastFilter.setValue(2.0, forKey: kCIInputContrastKey) // Strong contrast for B&W
            contrastFilter.setValue(0.15, forKey: kCIInputBrightnessKey) // Brightness adjustment
            contrastFilter.setValue(0, forKey: kCIInputSaturationKey) // Remove all color
            guard let contrastOutput = contrastFilter.outputImage else { return nil }
            
            // Step 3: Apply exposure adjustment for better clarity
            guard let exposureFilter = CIFilter(name: "CIExposureAdjust") else { return nil }
            exposureFilter.setValue(contrastOutput, forKey: kCIInputImageKey)
            exposureFilter.setValue(0.6, forKey: kCIInputEVKey)
            guard let exposureOutput = exposureFilter.outputImage else { return nil }
            
            // Step 4: Sharpen the image to make text clearer
            guard let sharpenFilter = CIFilter(name: "CISharpenLuminance") else { return nil }
            sharpenFilter.setValue(exposureOutput, forKey: kCIInputImageKey)
            sharpenFilter.setValue(1.2, forKey: kCIInputSharpnessKey) // Stronger sharpening
            guard let sharpenOutput = sharpenFilter.outputImage else { return nil }
            
            // Step 5: Apply binarization (thresholding) for pure black text on white background
            let binarizedImage = applyAdaptiveThreshold(to: sharpenOutput, context: context)
            
            // Convert back to UIImage
            guard let cgImage = context.createCGImage(binarizedImage, from: binarizedImage.extent) else { return nil }
            return UIImage(cgImage: cgImage)
        }
        
        /// Applies adaptive thresholding for strong binarization
        /// Creates pure black and white document effect
        private func applyAdaptiveThreshold(to image: CIImage, context: CIContext) -> CIImage {
            // Use color invert and threshold for strong binarization effect
            guard let invertFilter = CIFilter(name: "CIColorInvert") else { return image }
            invertFilter.setValue(image, forKey: kCIInputImageKey)
            guard let invertedImage = invertFilter.outputImage else { return image }
            
            // Apply stronger threshold using color matrix for pure B&W
            let thresholdValue: CGFloat = 0.6 // Higher threshold for stronger B&W effect
            let colorMatrix = CIFilter(name: "CIColorMatrix")
            colorMatrix?.setValue(invertedImage, forKey: kCIInputImageKey)
            
            // Create a strong threshold effect - pure black and white
            colorMatrix?.setValue(CIVector(x: 2.0, y: 0, z: 0, w: 0), forKey: "inputRVector")
            colorMatrix?.setValue(CIVector(x: 0, y: 2.0, z: 0, w: 0), forKey: "inputGVector")
            colorMatrix?.setValue(CIVector(x: 0, y: 0, z: 2.0, w: 0), forKey: "inputBVector")
            colorMatrix?.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
            colorMatrix?.setValue(CIVector(x: -thresholdValue, y: -thresholdValue, z: -thresholdValue, w: 0), forKey: "inputBiasVector")
            
            guard let thresholdOutput = colorMatrix?.outputImage else { return image }
            
            // Invert back to get pure black text on white background
            guard let finalInvertFilter = CIFilter(name: "CIColorInvert") else { return thresholdOutput }
            finalInvertFilter.setValue(thresholdOutput, forKey: kCIInputImageKey)
            
            return finalInvertFilter.outputImage ?? image
        }
        
        // MARK: - PDF Creation
        
        /// Creates a PDF from an array of images
        private func createPDF(from images: [UIImage]) -> URL? {
            let pdfDocument = PDFDocument()
            
            for (index, image) in images.enumerated() {
                // Create a PDF page from the image
                if let pdfPage = createPDFPage(from: image) {
                    pdfDocument.insert(pdfPage, at: index)
                }
            }
            
            // Save PDF to temporary directory
            // TODO: Upload this PDF to backend instead of just saving locally
            let fileName = "scanned_document_\(Date().timeIntervalSince1970).pdf"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            if pdfDocument.write(to: tempURL) {
                // Also save to Files app (Documents directory)
                if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let finalURL = documentsURL.appendingPathComponent(fileName)
                    do {
                        // Copy from temp to documents
                        try FileManager.default.copyItem(at: tempURL, to: finalURL)
                        print("PDF saved to: \(finalURL.path)")
                        return finalURL
                    } catch {
                        print("Error saving PDF to documents: \(error)")
                        return tempURL
                    }
                }
                return tempURL
            }
            
            return nil
        }
        
        /// Creates a PDF page from a UIImage
//        private func createPDFPage(from image: UIImage) -> PDFPage? {
//            // Create a temporary file to store the single-page PDF
//            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
//            let pdfPageBounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
//
//            // Create PDF context
//            guard let pdfContext = CGContext(tempURL as CFURL, mediaBox: nil, nil) else {
//                return nil
//            }
//
//            pdfContext.beginPDFPage(nil)
//
//            // Flip the context because PDF context has inverted Y-axis
//            pdfContext.translateBy(x: 0, y: pdfPageBounds.height)
//            pdfContext.scaleBy(x: 1.0, y: -1.0)
//
//            // Draw the image
//            if let cgImage = image.cgImage {
//                pdfContext.draw(cgImage, in: pdfPageBounds)
//            }
//
//            pdfContext.endPDFPage()
//            pdfContext.closePDF()
//
//            // Create PDFPage from the file
//            if let pdfDocument = PDFDocument(url: tempURL),
//               let pdfPage = pdfDocument.page(at: 0) {
//                // Clean up temp file
//                try? FileManager.default.removeItem(at: tempURL)
//                return pdfPage
//            }
//
//            // Clean up temp file on failure
//            try? FileManager.default.removeItem(at: tempURL)
//            return nil
//        }
        private func createPDFPage(from image: UIImage) -> PDFPage? {
            // Use the image's actual size for the PDF page
            let pageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
            
            let data = renderer.pdfData { context in
                context.beginPage()
                // Draw the image - UIKit handles orientation automatically
                image.draw(in: pageRect)
            }
            
            // Create PDFPage from the data
            if let pdfDocument = PDFDocument(data: data),
               let pdfPage = pdfDocument.page(at: 0) {
                return pdfPage
            }
            
            return nil
        }
    }
}

// MARK: - Preview Helper

struct DocumentScannerPreview: View {
    @State private var showScanner = false
    @State private var scannedPDFURL: URL?
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Open Document Scanner") {
                showScanner = true
            }
            .buttonStyle(.borderedProminent)
            
            if let pdfURL = scannedPDFURL {
                Text("PDF saved at:")
                    .font(.headline)
                Text(pdfURL.lastPathComponent)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showScanner) {
            DocumentScannerView(isPresented: $showScanner) { pdfURL in
                scannedPDFURL = pdfURL
                showAlert = true
            }
        }
        .alert("Scan Complete", isPresented: $showAlert) {
            Button("OK") {
                showAlert = false
            }
        } message: {
            Text("Document has been scanned and saved as PDF.")
        }
    }
}

#Preview {
    DocumentScannerPreview()
}
