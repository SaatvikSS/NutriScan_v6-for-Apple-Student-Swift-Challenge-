//
//  ProductDetailSheet.swift
//  NutriScan_v4
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.
//

import SwiftUI

struct ProductDetailSheet: View {
    let product: Product
    @Binding var isPresented: Bool
    
    // Define consistent colors
    private let primaryGreen = Color("PrimaryGreen")
    private let lightGreen = Color("LightGreen")
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Health Score Card
                    VStack(spacing: 8) {
                        Text("Health Score")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text(String(format: "%.1f", product.healthScore))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(scoreColor)
                        
                        // Score description
                        Text(scoreDescription)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                    
                    if let barcode = product.barcode {
                        Text("Barcode: \(barcode)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ingredients")
                            .font(.system(size: 20, weight: .bold))
                        
                        ForEach(product.ingredients) { ingredient in
                            IngredientCard(ingredient: ingredient)
                        }
                    }
                }
                .padding()
            }
            .background(colorScheme == .dark ? Color.black : lightGreen)
            .navigationTitle(product.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var scoreColor: Color {
        switch product.healthScore {
        case 4...: return .green
        case 2.5..<4: return primaryGreen
        default: return .red
        }
    }
    
    private var scoreDescription: String {
        switch product.healthScore {
        case 4...: return "This product has excellent nutritional value"
        case 2.5..<4: return "This product has moderate nutritional value"
        default: return "This product has poor nutritional value"
        }
    }
}

struct IngredientCard: View {
    let ingredient: Ingredient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ingredient.name)
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                CategoryPill(category: ingredient.category)
            }
            
            Text(ingredient.description)
                .font(.system(size: 15))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }
}

struct CategoryPill: View {
    let category: IngredientCategory
    
    var body: some View {
        Text(category.rawValue.capitalized)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(pillTextColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(pillBackgroundColor)
            .cornerRadius(12)
    }
    
    private var pillBackgroundColor: Color {
        switch category {
        case .good: return Color.green.opacity(0.2)
        case .neutral: return Color.gray.opacity(0.2)
        case .bad: return Color.red.opacity(0.2)
        }
    }
    
    private var pillTextColor: Color {
        switch category {
        case .good: return .green
        case .neutral: return .gray
        case .bad: return .red
        }
    }
}

#Preview {
    ProductDetailSheet(
        product: Product(
            name: "Test Product",
            barcode: "123456789",
            ingredients: [
                Ingredient(name: "Water", category: .good, description: "Essential for life"),
                Ingredient(name: "Sugar", category: .bad, description: "Added sweetener"),
                Ingredient(name: "Salt", category: .neutral, description: "Natural preservative")
            ],
            healthScore: 3.5
        ),
        isPresented: .constant(true)
    )
} 
