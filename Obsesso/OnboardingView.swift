//
//  OnboardingView.swift
//  Obsesso
//
//  Created by Ege Çam on 18.09.2024.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "checkmark.circle.fill",
            title: "Welcome to Obsesso",
            description: "Your personal double-check logger for peace of mind",
            preview: AnyView(Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.indigo)
                .frame(width: 100, height: 100))
        ),
        OnboardingPage(
            title: "Record Your Actions",
            description: "Capture short videos of your double-checks",
            preview: AnyView(PreviewViews.recordActionPreview)
        ),
        OnboardingPage(
            title: "Review Past Checks",
            description: "Easily access your history of double-checks",
            preview: AnyView(PreviewViews.pastChecksPreview)
        ),
        OnboardingPage(
            title: "Home Screen Reminder",
            description: "See your latest double-check right on Obsesso's home screen",
            preview: AnyView(PreviewViews.homeScreenPreview)
        ),
        OnboardingPage(
            title: "Widgets",
            description: "Add Obsesso widget to your home screen for quick access",
            preview: AnyView(PreviewViews.widgetPreview)
        )
    ]
    
    var body: some View {
        ZStack {
            Color.indigo.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            pages[index].preview
                                .frame(height: 250)
                                .padding()
                            
                            Text(pages[index].title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(pages[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onComplete()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.indigo)
                        .cornerRadius(10)
                }
                .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: currentPage)
                .padding()
            }
        }
    }
}

struct PreviewViews {
    static var recordActionPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 5)
            
            VStack {
                Spacer()
                
                Text("Car Lock")
                    .font(.title3)
                    .foregroundColor(.black)
                
                Text("I locked my car")
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "video.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.indigo)
                
                Spacer()
            }
            .padding()
        }
        .frame(width: 250, height: 250)
    }
    
    static var pastChecksPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent Double-Checks")
                    .font(.headline)
                
                ForEach(["Car Lock", "Stove Off", "Front Door"], id: \.self) { item in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(item)
                        Spacer()
                        Text("2h ago")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding()
        }
        .foregroundColor(.black)
        .frame(width: 250, height: 250)
    }
    
    static var homeScreenPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 10) {
                
                
                Text("You have")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Locked the front door")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("15 minutes ago")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .foregroundColor(.black)
        .frame(width: 250, height: 250)
    }
    
    static var widgetPreview: some View {
        ZStack {
            // iPhone frame
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 225, height: 440)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .mask(LinearGradient(gradient: Gradient(stops: [
                    .init(color: .black, location: 0),
                    .init(color: .clear, location: 0.5),
                ]), startPoint: .top, endPoint: .bottom))
            
            // Home screen background (blurred effect)
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: 205, height: 420)
                .cornerRadius(30)
                .blur(radius: 2)
                .mask(LinearGradient(gradient: Gradient(stops: [
                    .init(color: .black, location: 0),
                    .init(color: .clear, location: 0.5),
                ]), startPoint: .top, endPoint: .bottom))
                
            
            // Widget
            VStack(alignment: .leading, spacing: 8) {
                Text("Obsesso")
                    .font(.caption)
                    .foregroundColor(.white)
                
                Text("I locked my car")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("10 minutes ago")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                
                Spacer()
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.indigo.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: 205, height: 420)
                .cornerRadius(30)
                .blur(radius: 2))
            .cornerRadius(20)
            .frame(width: 150, height: 150)
            .position(x: 100, y: 100)  // Position widget at top-left
        }
        .frame(width: 250, height: 450)
        .offset(y: 125)
    }
}

struct OnboardingPage {
    let image: String?
    let title: String
    let description: String
    let preview: AnyView
    
    init(image: String? = nil, title: String, description: String, preview: AnyView) {
        self.image = image
        self.title = title
        self.description = description
        self.preview = preview
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onComplete: {})
    }
}
