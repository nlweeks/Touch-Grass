//
//  LocationPage.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/23/25.
//


import SwiftUI

struct LocationPage: View {
    @Binding var profile: Profile
    @State private var searchText = ""
    
    // Example locations - in a real app you might fetch these or use a location API
    let locations = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia",
                     "San Antonio", "San Diego", "Dallas", "San Jose", "Kansas City"]
    
    var filteredLocations: [String] {
        if searchText.isEmpty {
            return locations
        } else {
            return locations.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Where are you located?")
                .font(.title)
                .fontWeight(.bold)
            
            GroupBox {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if #available(iOS 17.0, *) {
                        // iOS 17 approach with searchable
                        TextField("Search locations", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .padding(.bottom, 10)
                        
                        List(filteredLocations, id: \.self) { location in
                            Button(action: {
                                profile.chosenLocation = location
                            }) {
                                HStack {
                                    Text(location)
                                    Spacer()
                                    if profile.chosenLocation == location {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                        .listStyle(.plain)
                    } else {
                        // Fallback for iOS 16 and earlier
                        TextField("Search locations", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                        
                        ScrollView {
                            LazyVStack(alignment: .leading) {
                                ForEach(filteredLocations, id: \.self) { location in
                                    Button(action: {
                                        profile.chosenLocation = location
                                    }) {
                                        HStack {
                                            Text(location)
                                            Spacer()
                                            if profile.chosenLocation == location {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                    }
                                    .foregroundColor(.primary)
                                    
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 400)
        }
        .padding()
    }
}
