//
//  OnboardInfoView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/16/25.
//

import SwiftUI

struct OnboardInfoView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var inputPage: InputPage = .one
    @State private var updatedProfile: Profile?
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    var body: some View {
        VStack {
            if let profile = updatedProfile {
                TabView(selection: $inputPage) {
                    // Basic Info
                    PersonalInfoPage(profile: Binding(
                        get: { profile },
                        set: { updatedProfile = $0 }
                    ))
                    .tag(InputPage.one)
                    
                    // Location
                    LocationPage(profile: Binding(
                        get: { profile },
                        set: { updatedProfile = $0 }
                    ))
                    .tag(InputPage.two)
                    
                    // Education & Work
                    EducationAndWorkPage(profile: Binding(
                        get: { profile },
                        set: { updatedProfile = $0 }
                    ))
                    .tag(InputPage.three)
                    
                    // Hobbies & Preferences
                    HobbiesPage(profile: Binding(
                        get: { profile },
                        set: { updatedProfile = $0 }
                    ))
                    .tag(InputPage.four)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: inputPage)
                
                HStack {
                    if inputPage != .one {
                        Button("Back") {
                            if let prevPage = inputPage.previous {
                                withAnimation {
                                    inputPage = prevPage
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    Button(inputPage.isLast ? "Finish" : "Next") {
                        if validateCurrentPage() {
                            withAnimation {
                                if inputPage.isLast {
                                    // Preserve the UID from the current profile
                                    var finalProfile = profile
                                    
                                    // Critical: Make sure we have the UID
                                    if finalProfile.uid == nil, let currentUID = appViewModel.currentUserProfile?.uid {
                                        print("Restoring missing UID: \(currentUID)")
                                        finalProfile.uid = currentUID
                                    }
                                    
                                    print("Saving final profile with UID: \(finalProfile.uid ?? "still nil")")
                                    
                                    // Save the updated profile
                                    appViewModel.completeOnboarding(updatedProfile: finalProfile)
                                } else if let nextPage = inputPage.next {
                                    inputPage = nextPage
                                }
                            }
                        } else {
                            showingValidationAlert = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                ProgressView("Loading profile...")
            }
        }
        .onAppear {
            // Initialize with the current user profile
            if let currentProfile = appViewModel.currentUserProfile {
                print("OnboardInfoView setting profile with UID: \(currentProfile.uid ?? "nil")")
                updatedProfile = currentProfile
            } else {
                print("WARNING: No current profile available in OnboardInfoView")
            }
        }
        .alert("Please Fill Required Fields", isPresented: $showingValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }
    
    // Validation logic with more detailed feedback
    func validateCurrentPage() -> Bool {
        guard let profile = updatedProfile else {
            validationMessage = "Profile data is missing."
            return false
        }
        
        switch inputPage {
        case .one:
            if profile.firstName?.isEmpty ?? true {
                validationMessage = "Please enter your first name."
                return false
            }
            if profile.lastName?.isEmpty ?? true {
                validationMessage = "Please enter your last name."
                return false
            }
            return true
            
        case .two:
            if profile.chosenLocation?.isEmpty ?? true {
                validationMessage = "Please select a location."
                return false
            }
            return true
            
        case .three:
            // Make education level required but not college/job
            if profile.educationLevel == nil {
                validationMessage = "Please select your education level."
                return false
            }
            return true
            
        case .four:
            if profile.hobbies?.isEmpty ?? true {
                validationMessage = "Please select at least one hobby."
                return false
            }
            return true
        }
    }
}

// Enhanced InputPage enum with previous page support
enum InputPage: Int, CaseIterable {
    case one, two, three, four
    
    var title: String {
        switch self {
        case .one: return "Personal Info"
        case .two: return "Location"
        case .three: return "Education & Work"
        case .four: return "Hobbies & Interests"
        }
    }
    
    var next: InputPage? {
        let allCases = Self.allCases
        if let currentIndex = allCases.firstIndex(of: self),
           currentIndex + 1 < allCases.count {
            return allCases[currentIndex + 1]
        }
        return nil
    }
    
    var previous: InputPage? {
        let allCases = Self.allCases
        if let currentIndex = allCases.firstIndex(of: self),
           currentIndex > 0 {
            return allCases[currentIndex - 1]
        }
        return nil
    }
    
    var isLast: Bool {
        return self == Self.allCases.last
    }
}

// Personal Info Page
struct PersonalInfoPage: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tell us about yourself")
                .font(.largeTitle)
                .fontWeight(.bold)
            
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
            
            Spacer()
        }
        .padding()
    }
}

// Location Page
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
        VStack(spacing: 20) {
            Text("Where are you located?")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading) {
                Text("Location").font(.caption).foregroundColor(.secondary)
                
                if #available(iOS 17.0, *) {
                    // iOS 17 approach with searchable
                    TextField("Search locations", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    
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
        .padding()
    }
}

// Main Education and Work Page
struct EducationAndWorkPage: View {
    @Binding var profile: Profile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Education & Work")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Education section
                EducationSection(profile: $profile)
                
                // Work section
                WorkSection(profile: $profile)
            }
            .padding()
        }
    }
}

// Education Section Component
struct EducationSection: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Education").font(.headline)
            
            EducationLevelPicker(profile: $profile)
            CollegeField(profile: $profile)
        }
    }
}

struct EducationLevelPicker: View {
    @Binding var profile: Profile
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Education Level").font(.caption).foregroundColor(.secondary)
            
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
            Text("Work").font(.headline)
            
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

// Hobbies Page
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
        VStack(spacing: 20) {
            Text("What do you enjoy?")
                .font(.largeTitle)
                .fontWeight(.bold)
            
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
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
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
#Preview {
    OnboardInfoView()
        .environment(AppViewModel())
}
