//
//  Touch_GrassApp.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI

@main
struct Touch_GrassApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var appController: AppViewModel? = nil
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appController ?? AppViewModel())
                .task {
                    if appController == nil {
                        appController = AppViewModel()
                    }
                }
        }
    }
}
