//
//  ContentView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppController.self) private var appController
    
    var body: some View {
        Group {
            switch appController.authState {
            case .undefined:
                ProgressView()
            case .notAuthenticated:
                AuthView()
            case .authenticated:
                ProfileView()
            }
        }
    }
}

#Preview {
    ContentView()
}
