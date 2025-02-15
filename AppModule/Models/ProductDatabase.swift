//
//  ProductDatabase.swift
//  NutriScan_v4
//
//  Created by Saatvik Shashank Shrivastava on 05/02/25.
//

import Foundation

struct ProductDatabase {
    static let shared = ProductDatabase()
    
    private var products: [String: Product] = [
        // Beverages
        "0049000006346": Product(  // Coca-Cola 12oz can
            name: "Coca-Cola Classic",
            barcode: "049000006346",
            ingredients: [
                Ingredient(name: "Carbonated Water", category: .neutral, description: "Base ingredient"),
                Ingredient(name: "High Fructose Corn Syrup", category: .bad, description: "Added sweetener, high in calories"),
                Ingredient(name: "Caramel Color", category: .neutral, description: "Artificial coloring"),
                Ingredient(name: "Phosphoric Acid", category: .bad, description: "Acidulant, may affect bone density"),
                Ingredient(name: "Natural Flavors", category: .neutral, description: "Proprietary flavor blend"),
                Ingredient(name: "Caffeine", category: .neutral, description: "Stimulant, 34mg per 12 fl oz")
            ],
            healthScore: 2.0
        ),
        
        // Snacks
        "0028400078269": Product(  // Doritos Nacho Cheese
            name: "Doritos Nacho Cheese",
            barcode: "0028400078269",
            ingredients: [
                Ingredient(name: "Corn", category: .neutral, description: "Main ingredient, whole grain corn"),
                Ingredient(name: "Vegetable Oil", category: .bad, description: "High in saturated fats, includes corn, canola, and/or sunflower oil"),
                Ingredient(name: "Maltodextrin", category: .bad, description: "Processed food additive"),
                Ingredient(name: "Salt", category: .bad, description: "High sodium content"),
                Ingredient(name: "Cheese Seasoning", category: .neutral, description: "Contains milk, artificial flavors"),
                Ingredient(name: "MSG", category: .bad, description: "Flavor enhancer")
            ],
            healthScore: 2.5
        ),
        
        // Healthy Foods
        "0016000264694": Product(  // Nature Valley Granola Bars
            name: "Nature Valley Crunchy Oats 'n Honey",
            barcode: "0016000264694",
            ingredients: [
                Ingredient(name: "Whole Grain Oats", category: .good, description: "Rich in fiber and nutrients"),
                Ingredient(name: "Sugar", category: .bad, description: "Added sweetener"),
                Ingredient(name: "Canola Oil", category: .neutral, description: "Heart-healthy oil"),
                Ingredient(name: "Honey", category: .neutral, description: "Natural sweetener"),
                Ingredient(name: "Salt", category: .neutral, description: "Flavor enhancer"),
                Ingredient(name: "Baking Soda", category: .neutral, description: "Leavening agent")
            ],
            healthScore: 3.5
        ),
        
        // Dairy
        "0894700010137": Product(  // Chobani Greek Yogurt
            name: "Chobani Plain Greek Yogurt",
            barcode: "0894700010137",
            ingredients: [
                Ingredient(name: "Cultured Milk", category: .good, description: "High in protein and calcium"),
                Ingredient(name: "Live Active Cultures", category: .good, description: "Probiotics for gut health"),
                Ingredient(name: "Cream", category: .neutral, description: "Adds texture and healthy fats"),
                Ingredient(name: "Milk Protein Concentrate", category: .good, description: "Additional protein source")
            ],
            healthScore: 4.5
        ),
        
        // Fruits
        "0643126071631": Product(  // Dole Bananas
            name: "Banana",
            barcode: "0643126071631",
            ingredients: [
                Ingredient(name: "Fresh Banana", category: .good, description: "Natural fruit, rich in potassium, vitamin B6, and fiber")
            ],
            healthScore: 5.0
        ),
        
        // Cereal
        "0016000275287": Product(  // Cheerios
            name: "Cheerios Original",
            barcode: "0016000275287",
            ingredients: [
                Ingredient(name: "Whole Grain Oats", category: .good, description: "Heart-healthy whole grain"),
                Ingredient(name: "Corn Starch", category: .neutral, description: "Thickening agent"),
                Ingredient(name: "Sugar", category: .bad, description: "Added sweetener"),
                Ingredient(name: "Salt", category: .neutral, description: "Flavor enhancer"),
                Ingredient(name: "Vitamins and Minerals", category: .good, description: "Added nutrients including iron and B vitamins")
            ],
            healthScore: 4.0
        ),
        
        // Plant-based
        "0852629004668": Product(
            name: "Beyond Meat Burger Patties",
            barcode: "0852629004668",
            ingredients: [
                Ingredient(name: "Pea Protein", category: .good, description: "Plant-based protein source"),
                Ingredient(name: "Canola Oil", category: .neutral, description: "Plant-based oil"),
                Ingredient(name: "Coconut Oil", category: .neutral, description: "Plant-based fat"),
                Ingredient(name: "Rice Protein", category: .good, description: "Additional plant protein"),
                Ingredient(name: "Beet Juice Extract", category: .good, description: "Natural coloring")
            ],
            healthScore: 3.8
        )
    ]
    
    func getProduct(barcode: String) -> Product? {
        print("Looking up barcode: \(barcode)") // Debug print
        print("Available barcodes: \(products.keys.joined(separator: ", "))") // Debug print
        return products[barcode]
    }
}
