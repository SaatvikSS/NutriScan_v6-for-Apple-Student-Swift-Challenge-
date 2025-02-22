import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to NutriScan",
            description: "Your personal nutrition assistant that helps you make informed food choices by scanning product labels.",
            imageName: "camera.viewfinder"
        ),
        OnboardingPage(
            title: "Instant Nutrition Info",
            description: "Simply point your camera at any food product's barcode to get detailed nutritional information and ingredients.",
            imageName: "text.viewfinder"
        ),
        OnboardingPage(
            title: "Make Better Choices",
            description: "Make healthier food choices with NutriScan.",
            imageName: "heart.text.square"
        )
    ]
}
