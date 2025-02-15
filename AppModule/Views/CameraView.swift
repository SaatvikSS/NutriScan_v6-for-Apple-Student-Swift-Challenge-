//
//  CameraView.swift
//  NutriScan_v6
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.

@preconcurrency import SwiftUI
@preconcurrency import AVFoundation
@preconcurrency import Vision

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ScannerViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        func setupCamera() {
            guard let captureDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) else {
                viewModel.error = .invalidDeviceInput
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
                
                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.setSampleBufferDelegate(
                    context.coordinator,
                    queue: DispatchQueue(label: "videoQueue")
                )
                
                if captureSession.canAddOutput(videoOutput) {
                    captureSession.addOutput(videoOutput)
                }
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.frame = viewController.view.bounds
                previewLayer.videoGravity = .resizeAspectFill
                viewController.view.layer.addSublayer(previewLayer)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    captureSession.startRunning()
                }
            } catch {
                viewModel.error = .invalidDeviceInput
            }
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        setupCamera()
                    }
                } else {
                    viewModel.error = .cameraPermissionDenied
                }
            }
        case .denied, .restricted:
            viewModel.error = .cameraPermissionDenied
        @unknown default:
            viewModel.error = .cameraSetupFailed
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
        let parent: CameraView
        private var isProcessing = false
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard !isProcessing,
                  let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            isProcessing = true
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            
            let barcodeRequest = VNDetectBarcodesRequest { [weak self] request, error in
                guard let self = self else { return }
                defer { self.isProcessing = false }
                
                if error != nil {
                    Task {
                        await MainActor.run {
                            self.parent.viewModel.error = .imageProcessingFailed
                        }
                    }
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation],
                      let barcode = results.first?.payloadStringValue else { return }
                
                Task {
                    await MainActor.run {
                        self.parent.viewModel.scannedCode = barcode
                        self.parent.viewModel.stopScanning()
                    }
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try VNImageRequestHandler(ciImage: ciImage).perform([barcodeRequest])
                } catch {
                    Task {
                        await MainActor.run {
                            self.parent.viewModel.error = .imageProcessingFailed
                        }
                    }
                }
            }
        }
    }
}
