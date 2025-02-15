//
//  Product.swift
//  NutriScan_v4
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.
//

import Foundation

struct Product: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let barcode: String?
    let ingredients: [Ingredient]
    let healthScore: Double
    let scanDate: Date
    
    init(id: UUID = UUID(), name: String, barcode: String? = nil, ingredients: [Ingredient], healthScore: Double, scanDate: Date = Date()) {
        self.id = id
        self.name = name
        self.barcode = barcode
        self.ingredients = ingredients
        self.healthScore = healthScore
        self.scanDate = scanDate
    }
}

struct Ingredient: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let category: IngredientCategory
    let description: String
    
    init(id: UUID = UUID(), name: String, category: IngredientCategory, description: String) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
    }
}

enum IngredientCategory: String, Codable {
    case good
    case neutral
    case bad
    
    var color: String {
        switch self {
        case .good: return "green"
        case .neutral: return "gray"
        case .bad: return "red"
        }
    }
}
