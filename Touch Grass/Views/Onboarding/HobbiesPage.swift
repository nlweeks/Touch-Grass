//
//  HobbiesPage.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/23/25.
//

import SwiftUI

struct HobbiesPage: View {
    @Binding var profile: Profile
    @State private var selectedHobbies: Set<Profile.Hobbies> = []
    @State private var searchText = ""
    
    var filteredHobbies: [Profile.Hobbies] {
        if searchText.isEmpty {
            return Profile.Hobbies.allCases
        } else {
            return Profile.Hobbies.allCases.filter { hobby in
                hobby.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("What do you enjoy?")
                .font(.title)
                .fontWeight(.bold)
            
            GroupBox {
                VStack(spacing: 15){
                    TextField("Search hobbies", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(filteredHobbies, id: \.self) { hobby in
                                HobbyToggleButton(
                                    hobby: hobby,
                                    isSelected: selectedHobbies.contains(hobby),
                                    action: {
                                        if selectedHobbies.contains(hobby) {
                                            selectedHobbies.remove(hobby)
                                        } else {
                                            selectedHobbies.insert(hobby)
                                        }
                                        profile.hobbies = Array(selectedHobbies)
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            // Initialize selected hobbies from profile
            if let hobbies = profile.hobbies {
                selectedHobbies = Set(hobbies)
            }
        }
    }
}

struct HobbyToggleButton: View {
    let hobby: Profile.Hobbies
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(hobby.emoji)
                Text(hobby.displayName)
                    .font(.subheadline)
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
