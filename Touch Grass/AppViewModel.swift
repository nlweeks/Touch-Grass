//
//  AppController.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum AppState {
    case authentication, onboarding, mainApp
}

@Observable
class AppViewModel {
    // MARK: - Overall App State
    // Checks if user is logged in
    var appState: AppState = .authentication
    
    // MARK: - AuthView UI Inputs
    var email = ""
    var password = ""
    
    // MARK: - Stored User Profile (from Firestore)
    var currentUserProfile: Profile?
    
    // MARK: - Auth Changes + Sync With Firestore Profile
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var profileListener: ListenerRegistration?
    
    init() {
        listenToAuthChanges()
    }
    
    deinit {
        removeAuthStateListener()
        removeProfileListener()
    }
    
    private func listenToAuthChanges() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // Start listening to user profile
                self.startListeningToUserProfile(uid: user.uid)
            } else {
                // User is logged out
                self.appState = .authentication
                self.currentUserProfile = nil
                self.removeProfileListener()
            }
        }
    }
    
    private func removeAuthStateListener() {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authStateListenerHandle = nil
        }
    }
    
    private func startListeningToUserProfile(uid: String) {
        // Remove existing listener if any
        removeProfileListener()
        
        print("Starting to listen for profile with UID: \(uid)")
        
        // Track creation attempts to prevent duplicates
        var creationInProgress = false
        
        profileListener = FirestoreController<Profile>.listen(uid: uid, collectionPath: Path.Firestore.profiles) { [weak self] profile, exists in
            guard let self = self else { return }
            
            print("Profile listener triggered - exists: \(exists)")
            
            if exists {
                if let profile = profile {
                    print("Retrieved profile with UID: \(profile.uid ?? "nil")")
                    self.currentUserProfile = profile
                    
                    // Determine app state based on profile completeness
                    if self.isProfileComplete() {
                        self.appState = .mainApp
                    } else {
                        self.appState = .onboarding
                    }
                }
            } else if !creationInProgress {
                // Prevent duplicate creation
                creationInProgress = true
                
                print("No profile found - creating new profile for UID: \(uid)")
                Task {
                    do {
                        try await self.createUserProfile()
                        self.appState = .onboarding
                        creationInProgress = false
                    } catch {
                        print("Error creating user profile: \(error)")
                        creationInProgress = false
                    }
                }
            }
        }
    }
    
    private func removeProfileListener() {
        profileListener?.remove()
        profileListener = nil
    }
    
    // Helper method to determine if a profile has completed onboarding
    private func isProfileComplete() -> Bool {
        guard let profile = currentUserProfile else { return false }
        
        // Define your criteria for a complete profile here
        // For example, check if essential fields are filled in
        return profile.firstName != nil &&
        profile.lastName != nil
    }
    
    // MARK: - Baseline Firebase Auth Functions
    func signUp() async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signIn() async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteUser() {
        let user = Auth.auth().currentUser
        user?.delete { err in
            if let err {
                print(err.localizedDescription)
            }
        }
    }
    
    // MARK: - Firestore Profile Management
    func createUserProfile() async throws {
        guard let user = Auth.auth().currentUser else {
            print("No user signed in.")
            return
        }
        
        print("Creating new profile with UID: \(user.uid)")
        
        // Create a profile with the Auth UID
        let profile = Profile(uid: user.uid, email: user.email ?? "")
        
        do {
            // Create the document with the Auth UID as the document ID
            let createdProfile = try await FirestoreController<Profile>.create(profile, collectionPath: Path.Firestore.profiles)
            self.currentUserProfile = createdProfile
            print("Profile created with UID: \(createdProfile.uid ?? "nil")")
        } catch {
            print("Error creating profile: \(error.localizedDescription)")
            throw error
        }
    }
    
    func completeOnboarding(updatedProfile: Profile) {
        // Critical check: Ensure we have a UID
        var profileToSave = updatedProfile
        
        if profileToSave.uid == nil {
            if let currentUserID = Auth.auth().currentUser?.uid {
                print("Setting missing UID from Auth: \(currentUserID)")
                profileToSave.uid = currentUserID
            } else {
                print("ERROR: Cannot complete onboarding - no UID available!")
                return
            }
        }
        
        print("Completing onboarding with profile UID: \(profileToSave.uid ?? "nil")")
        
        do {
            _ = try FirestoreController<Profile>.update(profileToSave, collectionPath: Path.Firestore.profiles)
            print("Profile successfully updated")
            
            // Update the current profile in memory too
            self.currentUserProfile = profileToSave
        } catch {
            print("Error updating profile: \(error)")
        }
    }
    
    func deleteUserProfile() {
        guard let profile = currentUserProfile else { return }
        
        do {
            _ = try FirestoreController<Profile>.delete(profile, collectionPath: Path.Firestore.profiles)
        } catch {
            print("Error deleting profile: \(error)")
        }
    }
    
    // MARK: - Firebase Auth Info Changes
    func updateUserProfile() {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = "Amber"
        changeRequest?.commitChanges { err in
            if let err {
                print(err.localizedDescription)
            }
        }
    }
}
