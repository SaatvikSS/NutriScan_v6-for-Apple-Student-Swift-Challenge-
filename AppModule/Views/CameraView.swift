//
//  CameraView.swift
//  NutriScan_v6
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.
//

import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ScannerViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        checkCameraPermission { isAuthorized in
            DispatchQueue.main.async {
                if isAuthorized {
                    self.setupCamera(on: viewController, context: context)
                } else {
                    self.viewModel.error = .cameraPermissionDenied
                }
            }
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func setupCamera(on viewController: UIViewController, context: Context) {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            DispatchQueue.main.async {
                self.viewModel.error = .invalidDeviceInput
            }
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = viewController.view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            viewController.view.layer.addSublayer(previewLayer)
            
            DispatchQueue.main.async {
                captureSession.startRunning()
            }
        } catch {
            DispatchQueue.main.async {
                self.viewModel.error = .invalidDeviceInput
            }
        }
    }

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
        let parent: CameraView
        private var isProcessing = false
        private var lastProcessedTime = Date().timeIntervalSince1970
        private var lastDetectedTime = Date().timeIntervalSince1970
        private var scanStartTime = Date().timeIntervalSince1970
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            let currentTime = Date().timeIntervalSince1970
            
            if isProcessing || (currentTime - lastProcessedTime < 1.0) { return }
            isProcessing = true
            lastProcessedTime = currentTime

            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                isProcessing = false
                return
            }
            
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)

            let barcodeRequest = VNDetectBarcodesRequest { [weak self] request, error in
                guard let self = self else { return }
                defer { self.isProcessing = false }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.parent.viewModel.error = .imageProcessingFailed
                    }
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation],
                      let barcode = results.first?.payloadStringValue else {
                    return
                }

                self.lastDetectedTime = Date().timeIntervalSince1970
                
                DispatchQueue.main.async {
                    self.parent.viewModel.scannedCode = barcode
                    self.parent.viewModel.stopScanning()
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                do {
                    let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
                    try requestHandler.perform([barcodeRequest])

                    
                } catch {
                    DispatchQueue.main.async {
                        self.parent.viewModel.error = .imageProcessingFailed
                    }
                }
            }
            
            if currentTime - scanStartTime > 60 {
                DispatchQueue.main.async {
                    self.parent.viewModel.stopScanning()
                    self.isProcessing = false
                }
            }

            if currentTime - lastDetectedTime > 10 {
                DispatchQueue.main.async {
                    self.parent.viewModel.stopScanning()
                    self.isProcessing = false
                }
            }
        }
    }
}

