//
//  PersonalInfoPage.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/23/25.
//


import SwiftUI

struct PersonalInfoPage: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Tell us about yourself")
                .font(.title)
                .fontWeight(.bold)
            
            GroupBox {
                VStack(alignment: .leading) {
                    Text("First Name").font(.caption).foregroundColor(.secondary)
                    TextField("First Name", text: Binding(
                        get: { profile.firstName ?? "" },
                        set: { profile.firstName = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.givenName)
                    .autocorrectionDisabled()
                }
                
                VStack(alignment: .leading) {
                    Text("Last Name").font(.caption).foregroundColor(.secondary)
                    TextField("Last Name", text: Binding(
                        get: { profile.lastName ?? "" },
                        set: { profile.lastName = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.familyName)
                    .autocorrectionDisabled()
                }
                
                VStack(alignment: .leading) {
                    Text("Gender").font(.caption).foregroundColor(.secondary)
                    Picker("Select Gender", selection: Binding(
                        get: { profile.gender ?? .other },
                        set: { profile.gender = $0 }
                    )) {
                        Text("Male").tag(Profile.UserGender.male)
                        Text("Female").tag(Profile.UserGender.female)
                        Text("Non-binary").tag(Profile.UserGender.nonbinary)
                        Text("Other").tag(Profile.UserGender.other)
                    }
                    .pickerStyle(.segmented)
                }
            }
            
//            Spacer()
        }
        .padding()
    }
}
