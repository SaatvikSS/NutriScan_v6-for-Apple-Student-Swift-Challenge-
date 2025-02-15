//
//  HomeView.swift
//  NutriScan_v4
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var scannerViewModel = ScannerViewModel()
    @State private var showingScanner = false
    @State private var showingResults = false
    @State private var buttonScale: CGFloat = 1.0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color.black : Color.white,
                        colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // App Title and Description
                    VStack(spacing: 16) {
                        Text("NutriScan")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Scan product barcodes")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)
                    
                    Spacer()
                    
                    // Scan Button
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            buttonScale = 0.9
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                buttonScale = 1.0
                            }
                            showingScanner = true
                        }
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 44, weight: .light))
                            Text("Tap to Scan")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 160, height: 160)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 10)
                        )
                    }
                    .scaleEffect(buttonScale)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: buttonScale)
                    
                    Spacer()
                    
                    // Instructions
                    Text("Point camera at product barcode")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 30)
                }
                .padding()
            }
            .onChange(of: scannerViewModel.scannedCode) { newValue in
                if newValue != nil {
                    withAnimation {
                        showingScanner = false
                        showingResults = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingScanner) {
            ScannerView(viewModel: scannerViewModel)
                .transition(.opacity)
        }
        .sheet(isPresented: $showingResults) {
            if let code = scannerViewModel.scannedCode {
                NavigationView {
                    ProductDetailView(barcode: code)
                        .navigationBarItems(trailing: Button("Done") {
                            withAnimation {
                                showingResults = false
                                scannerViewModel.scannedCode = nil
                            }
                        })
                }
            }
        }
    }
}
