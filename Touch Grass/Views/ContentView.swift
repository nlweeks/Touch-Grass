//
//  ContentView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        Group {
            switch appViewModel.appState {
            case .authentication:
                AuthView()
            case .onboarding:
                OnboardInfoView()
            case .mainApp:
                MainView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
}


