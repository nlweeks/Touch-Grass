//
//  EducationAndWork.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/23/25.
//

import SwiftUI

struct EducationAndWorkPage: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Education & Work")
                .font(.title)
                .fontWeight(.bold)
            
            GroupBox {
                EducationSection(profile: $profile)
                
                WorkSection(profile: $profile)
            }
        }
        .padding()
    }
}

// Education Section Component
struct EducationSection: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Education")
                .font(.title3)
                .bold()
            
            EducationLevelPicker(profile: $profile)
            CollegeField(profile: $profile)
        }
    }
}

struct EducationLevelPicker: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Education Level")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Create a local binding to simplify the picker
            let educationBinding = Binding<Profile.EducationLevel>(
                get: { self.profile.educationLevel ?? .other },
                set: { self.profile.educationLevel = $0 }
            )
            
            Picker("Select Education Level", selection: educationBinding) {
                ForEach(Profile.EducationLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

struct CollegeField: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("College/University (Optional)").font(.caption).foregroundColor(.secondary)
            
            // Create a local binding to simplify the text field
            let collegeBinding = Binding<String>(
                get: { self.profile.college ?? "" },
                set: { self.profile.college = $0.isEmpty ? nil : $0 }
            )
            
            TextField("Enter school name", text: collegeBinding)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
        }
    }
}

// Work Section Component
struct WorkSection: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Work")
                .font(.title3)
                .bold()
            
            ProfessionPicker(profile: $profile)
            JobTitleField(profile: $profile)
        }
    }
}

struct ProfessionPicker: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profession Category").font(.caption).foregroundColor(.secondary)
            
            let professionBinding = Binding<Profile.ProfessionCategory>(
                get: { self.profile.professionCategory ?? .other },
                set: { self.profile.professionCategory = $0 }
            )
            
            Picker("Select Profession", selection: professionBinding) {
                ForEach(Profile.ProfessionCategory.allCases, id: \.self) { profession in
                    Text(profession.rawValue).tag(profession)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

struct JobTitleField: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Job Title (Optional)").font(.caption).foregroundColor(.secondary)
            
            let jobTitleBinding = Binding<String>(
                get: { self.profile.jobTitle ?? "" },
                set: { self.profile.jobTitle = $0.isEmpty ? nil : $0 }
            )
            
            TextField("Enter job title", text: jobTitleBinding)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
        }
    }
}
