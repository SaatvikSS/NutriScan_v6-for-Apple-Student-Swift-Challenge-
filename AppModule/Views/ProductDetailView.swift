//
//  ProductDetailView.swift
//  NutriScan_v4
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.
//

import SwiftUI

struct ProductDetailView: View {
    let barcode: String
    @State private var product: Product?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading product details...")
            } else if let product = product {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Product Name
                        Text(product.name)
                            .font(.system(size: 28, weight: .bold))
                            .padding(.bottom, 4)
                        
                        // Barcode
                        HStack {
                            Text("Barcode:")
                                .font(.system(size: 17, weight: .medium))
                            Text(product.barcode ?? "N/A")
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                        }
                        
                        // Health Score
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Health Score")
                                .font(.system(size: 20, weight: .semibold))
                            HStack(spacing: 4) {
                                Text(String(format: "%.1f", product.healthScore))
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(healthScoreColor(product.healthScore))
                                Text("/ 5.0")
                                    .font(.system(size: 17))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Ingredients
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ingredients")
                                .font(.system(size: 20, weight: .semibold))
                            
                            if product.ingredients.isEmpty {
                                Text("No ingredients information available")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                ForEach(product.ingredients) { ingredient in
                                    IngredientRow(ingredient: ingredient)
                                }
                            }
                        }
                    }
                    .padding()
                }
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 44))
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .navigationTitle("Product Details")
        .onAppear {
            loadProduct()
        }
    }
    
    private func loadProduct() {
        Task {
            do {
                // Try to find the product in database
                if let databaseProduct = ProductDatabase.shared.getProduct(barcode: barcode) {
                    await MainActor.run {
                        self.product = databaseProduct
                        self.isLoading = false
                    }
                } else {
                    // Create a placeholder product if not found
                    let newProduct = Product(
                        name: "Unknown Product",
                        barcode: barcode,
                        ingredients: [],
                        healthScore: 0
                    )
                    await MainActor.run {
                        self.product = newProduct
                        self.isLoading = false
                        self.errorMessage = "Product not found in database"
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Error loading product: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func healthScoreColor(_ score: Double) -> Color {
        switch score {
        case 4.0...5.0:
            return .green
        case 2.5..<4.0:
            return .yellow
        default:
            return .red
        }
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ingredient.name)
                    .font(.system(size: 17, weight: .medium))
                Spacer()
                categoryBadge
            }
            
            if !ingredient.description.isEmpty {
                Text(ingredient.description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var categoryBadge: some View {
        Text(ingredient.category.rawValue.capitalized)
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .cornerRadius(6)
    }
    
    private var categoryColor: Color {
        switch ingredient.category {
        case .good:
            return .green
        case .neutral:
            return .yellow
        case .bad:
            return .red
        }
    }
}
