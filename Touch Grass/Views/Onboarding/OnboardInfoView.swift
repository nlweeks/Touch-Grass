//
//  OnboardInfoView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/16/25.
//

import SwiftUI

struct OnboardInfoView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var inputPage: InputPage = .four
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
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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

#Preview {
    let previewViewModel = AppViewModel()
    
    // Create a mock profile for preview
    var mockProfile = Profile(email: "test@example.com")
    mockProfile.uid = "preview-uid"
    mockProfile.firstName = "John"
    mockProfile.lastName = "Doe"
    mockProfile.gender = .male
    mockProfile.chosenLocation = "New York"
    mockProfile.educationLevel = .undergraduate
    mockProfile.college = "Sample University"
    mockProfile.professionCategory = .information
    mockProfile.jobTitle = "Developer"
    mockProfile.hobbies = [.hiking, .reading]  // Using actual enum values from your Profile.Hobbies
    
    previewViewModel.currentUserProfile = mockProfile
    
    return OnboardInfoView()
        .environment(previewViewModel)
}
