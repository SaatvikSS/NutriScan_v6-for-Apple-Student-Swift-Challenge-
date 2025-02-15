//
//  DataManager.swift
//  NutriScan_v4
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.
//

import Foundation

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    @Published var savedProducts: [Product] = []
    @Published var error: String?
    
    private let fileManager = FileManager.default
    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("scanned_products.json")
    }
    
    private init() {
        loadProducts()
    }
    
    func saveProduct(_ product: Product) async throws {
        if !savedProducts.contains(where: { $0.barcode == product.barcode }) {
            savedProducts.append(product)
            try await saveProducts()
        }
    }
    
    func deleteProduct(_ product: Product) async throws {
        savedProducts.removeAll { $0.id == product.id }
        try await saveProducts()
    }
    
    func findProduct(withBarcode barcode: String) async throws -> Product? {
        // First check the saved products
        if let savedProduct = savedProducts.first(where: { $0.barcode == barcode }) {
            return savedProduct
        }
        
        // Then check the product database
        if let databaseProduct = ProductDatabase.shared.getProduct(barcode: barcode) {
            // Save the product for future use
            try await saveProduct(databaseProduct)
            return databaseProduct
        }
        
        return nil
    }
    
    private func saveProducts() async throws {
        let data = try JSONEncoder().encode(savedProducts)
        try data.write(to: documentsURL)
    }
    
    private func loadProducts() {
        do {
            guard fileManager.fileExists(atPath: documentsURL.path) else { return }
            let data = try Data(contentsOf: documentsURL)
            savedProducts = try JSONDecoder().decode([Product].self, from: data)
        } catch {
            self.error = "Failed to load products: \(error.localizedDescription)"
        }
    }
}
