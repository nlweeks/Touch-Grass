//
//  ProfileView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI

struct MainView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        VStack {
            Text("Hello, \(appViewModel.currentUserProfile?.email ?? "World")!")
            
            Button("Logout") {
                do {
                    try appViewModel.signOut()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
    }
}

#Preview {
    MainView()
        .environment(AppViewModel())
}
