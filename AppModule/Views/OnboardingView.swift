import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(viewModel.onboardingPages.indices, id: \.self) { index in
                OnboardingPageView(page: viewModel.onboardingPages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            HStack {
                if viewModel.currentPage < viewModel.onboardingPages.count - 1 {
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .padding()
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("Next") {
                        withAnimation {
                            viewModel.currentPage += 1
                        }
                    }
                    .padding()
                    .foregroundColor(.blue)
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private func completeOnboarding() {
        viewModel.hasCompletedOnboarding = true
        dismiss()
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: page.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.blue)
            
            Text(page.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}
