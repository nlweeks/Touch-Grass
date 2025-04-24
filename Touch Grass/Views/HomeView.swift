//
//  HomeView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/23/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 3) {
                CalendarBoxView()
                    .padding()
                
                VStack {
                    Text("Upcoming Events")
                        .font(.title).bold()
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

struct CalendarBoxView: View {
    let daySymbolStrings = ["s.circle", "m.circle", "t.circle", "w.circle", "t.circle", "f.circle", "s.circle"]
    
    var body: some View {
        GroupBox {
            VStack(spacing: 10) {
                HStack {
                    Text("Your Social Calendar")
                        .font(.title).bold()
                    
                    Spacer()
                }
                
                HStack() {
                    ForEach(0..<7, id: \.self) { i in
                        Image(systemName: daySymbolStrings[i])
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }
}
