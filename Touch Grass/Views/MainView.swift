//
//  ProfileView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI

enum Tabs {
    case home, search, profile
}

struct MainView: View {
//    @Environment(AppViewModel.self) private var appViewModel
    
    @State private var currentTab: Tabs = .search
    
    var body: some View {
        TabView(selection: $currentTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(Tabs.home)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                .tag(Tabs.search)
            
            Text("John Doe")
                .tabItem {
                    Image(systemName: "person.circle")
                }
                .tag(Tabs.profile)
        }
    }
}

#Preview {
    MainView()
}
