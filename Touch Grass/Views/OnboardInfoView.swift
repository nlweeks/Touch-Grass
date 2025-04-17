//
//  OnboardInfoView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/16/25.
//

import SwiftUI

import SwiftUI

struct OnboardInfoView: View {
    @State private var inputPage: InputPage = .one
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TabView(selection: $inputPage) {
                    ForEach(InputPage.allCases, id: \.self) { page in
                        Text(page.title)
                            .tag(page)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: inputPage)
                
                Button(inputPage.isLast ? "Finish" : "Next") {
                    withAnimation {
                        if inputPage.isLast {
                            // Reset the navigation path to clear the stack
                            path = NavigationPath()
                            // Navigate to the main app view
                            path.append("MainAppView")
                        } else if let nextPage = inputPage.next {
                            inputPage = nextPage
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "MainAppView" {
                    MainView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

enum InputPage: Int, CaseIterable {
    case one, two, three, four
    
    var title: String {
        switch self {
        case .one: return "Hello, Page One!"
        case .two: return "Hello, Page Two!"
        case .three: return "Hello, Page Three!"
        case .four: return "Click below to finish!"
        }
    }
    
    var next: InputPage? {
        let allCases = Self.allCases
        if let currentIndex = allCases.firstIndex(of: self),
           currentIndex + 1 < allCases.count {
            return allCases[currentIndex + 1]
        }
        return nil
    }
    
    var isLast: Bool {
        return self == Self.allCases.last
    }
}

struct PostOnboardingView: View {
    var body: some View {
        Text("Welcome to the main app!")
            .font(.largeTitle)
            .padding()
    }
}


#Preview {
    OnboardInfoView()
        .environment(AppViewModel())
}
