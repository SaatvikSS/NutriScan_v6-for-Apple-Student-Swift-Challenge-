import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)
            
            SettingsView(isDarkMode: $isDarkMode, showOnboarding: $showOnboarding)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
        }
        .onAppear {
            if !hasCompletedOnboarding {
                showOnboarding = true
            }
        }
        .accentColor(Color("PrimaryGreen"))
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct HistoryView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            List {
                if dataManager.savedProducts.isEmpty {
                    Text("No scans yet")
                        .foregroundColor(.gray)
                } else {
                    ForEach(dataManager.savedProducts) { product in
                        NavigationLink(destination: ProductDetailSheet(product: product, isPresented: .constant(true))) {
                            ProductRow(product: product)
                        }
                    }
                    .onDelete(perform: deleteProducts)
                }
            }
            .navigationTitle("Scan History")
            .onAppear {
                print("HistoryView appeared")
                print("Saved Products Count: \(dataManager.savedProducts.count)")
            }
            .alert("Error", isPresented: .constant(error != nil)) {
                Button("OK") {
                    error = nil
                }
            } message: {
                if let error = error {
                    Text(error)
                }
            }
        }
    }
    
    private func deleteProducts(at offsets: IndexSet) {
        Task {
            do {
                for index in offsets {
                    let product = dataManager.savedProducts[index]
                    try await dataManager.deleteProduct(product)
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.headline)
            Text("Health Score: \(String(format: "%.1f", product.healthScore))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @Binding var showOnboarding: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                Section(header: Text("Help")) {
                    Button("View Walkthrough") {
                        showOnboarding = true
                    }
                }
                
                Section(header: Text("About")) {
                    Text("NutriScan v1.0")
                    Text(" 2025 All rights reserved")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
