import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("isDarkMode") private var isDarkMode = false
    
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
            
            SettingsView(isDarkMode: $isDarkMode)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
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
    @State private var isGlutenFree = false
    @State private var isVegan = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                Section(header: Text("Dietary Preferences")) {
                    Toggle("Gluten Free", isOn: $isGlutenFree)
                    Toggle("Vegan", isOn: $isVegan)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
