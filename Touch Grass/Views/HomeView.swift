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
            VStack(alignment: .leading, spacing: 20) {
                CalendarBoxView()
                    .padding()
                
                VStack {
                    Text("Upcoming Events")
                        .font(.title).bold()
                }
                .padding()
            }
        }
    }
}

struct CalendarBoxView: View {
    var body: some View {
        GroupBox {
            HStack {
                Spacer()
                
                Image(systemName: "s.circle")
                    .font(.title)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "m.circle")
                    .font(.title)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "t.circle")
                    .font(.title)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "w.circle")
                    .font(.title)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "t.circle")
                    .font(.title)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "f.circle")
                    .font(.title)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "s.circle")
                    .font(.title)
                    .foregroundStyle(.secondary)
                
                
                Spacer()
            }
        }
    }
}
