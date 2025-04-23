//
//  ProfileView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI

enum CurrentView {
    case home, search, profile
}

struct MainView: View {
//    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(CurrentView.home)
            
            Text("Search")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                .tag(CurrentView.search)
            
            Text("John Doe")
                .tabItem {
                    Image(systemName: "person.circle")
                }
                .tag(CurrentView.profile)
        }
    }
}

#Preview {
    MainView()
}
