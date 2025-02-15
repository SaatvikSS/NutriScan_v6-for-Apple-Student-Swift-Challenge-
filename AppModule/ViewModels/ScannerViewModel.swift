//
//  ScannerViewModel.swift
//  NutriScan_v4
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.
//

import SwiftUI
@MainActor
enum ScannerError: Error, @preconcurrency Identifiable {
    case cameraPermissionDenied
    case cameraSetupFailed
    case imageProcessingFailed
    case invalidDeviceInput
    case noBarcodeFound
    
    var id: String { message }
    
    var message: String {
        switch self {
        case .cameraPermissionDenied:
            return "Camera access is required. Please enable it in Settings."
        case .cameraSetupFailed:
            return "Failed to setup camera. Please try again."
        case .imageProcessingFailed:
            return "Failed to process image. Please try again."
        case .invalidDeviceInput:
                    return "Failed to setup camera input. Please try again."
        case .noBarcodeFound:
            return "No barcode found."
        }
    }
}

@MainActor
class ScannerViewModel: ObservableObject {
    @Published var isShowingScanner = false
    @Published var scannedCode: String?
    @Published var error: ScannerError?
    @Published private(set) var isScanning = false
    
    func startScanning() {
        isShowingScanner = true
        isScanning = true
        error = nil
        scannedCode = nil
    }
    
    func stopScanning() {
        isShowingScanner = false
        isScanning = false
    }
    
    func handleScanError(_ error: ScannerError) {
        self.error = error
        isScanning = false
    }
    
    func clearError() {
        error = nil
    }
}
