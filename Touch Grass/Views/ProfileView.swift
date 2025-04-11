//
//  ProfileView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppController.self) private var appController
    
    var body: some View {
        VStack {
            Text("Hello, ProfileView!")
            
            Button("Logout") {
                do {
                    try appController.signOut()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
    }
}

#Preview {
    ProfileView()
}
