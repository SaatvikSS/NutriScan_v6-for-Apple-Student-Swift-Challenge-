//
//  ScannerView.swift
//  NutriScan_v4
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.
//

import SwiftUI

struct ScannerOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(
                                        width: geometry.size.width * 0.8,
                                        height: geometry.size.width * 0.5
                                    )
                                    .blendMode(.destinationOut)
                            )
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(
                        width: geometry.size.width * 0.8,
                        height: geometry.size.width * 0.5
                    )
                
                // Scanner line animation
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: geometry.size.width * 0.8, height: 2)
                    .offset(y: -geometry.size.width * 0.25)
            }
        }
    }
}
struct ScannerView: View {
    @StateObject var viewModel: ScannerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            CameraView(viewModel: viewModel)
                .ignoresSafeArea()
            
            ScannerOverlay()
                .ignoresSafeArea()
            
            VStack {
                Button(action: {
                    viewModel.stopScanning()
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(24)
                
                Spacer()
                
                Text("Position barcode within frame")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            viewModel.startScanning()
        }
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.message),
                dismissButton: .default(Text("OK")) {
                    if error == .cameraPermissionDenied {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    dismiss()
                }
            )
        }
    }
}



