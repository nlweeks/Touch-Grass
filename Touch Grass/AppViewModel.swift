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
        
        // Set up the new listener using FirestoreController
        profileListener = FirestoreController<Profile>.listen(uid: uid, collectionPath: Path.Firestore.profiles) { [weak self] profile, exists in
            guard let self = self else { return }
            
            if exists {
                if let profile = profile {
                    self.currentUserProfile = profile
                    
                    // Determine app state based on profile completeness
                    if self.isProfileComplete() {
                        self.appState = .mainApp
                    } else {
                        self.appState = .onboarding
                    }
                }
            } else {
                // Profile document doesn't exist, create minimal profile and move to onboarding
                Task {
                    do {
                        try await self.createUserProfile()
                        self.appState = .onboarding
                    } catch {
                        print("Error creating user profile: \(error)")
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
        
        let profile = Profile(uid: user.uid, email: user.email ?? "")
        _ = try await FirestoreController<Profile>.create(profile, collectionPath: Path.Firestore.profiles)
    }
    
    func completeOnboarding(updatedProfile: Profile) {
        do {
            _ = try FirestoreController<Profile>.update(updatedProfile, collectionPath: Path.Firestore.profiles)
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
    
    //    func setUserEmail() {
    //        Auth.auth().currentUser?.updateEmail(to: "amber@example.com") { err in
    //            if let err {
    //                print(err.localizedDescription)
    //            }
    //        }
    //    }
    //
    //    func reAuthenticate() {
    //        let user = Auth.auth().currentUser
    //        let credential = EmailAuthProvider.credential(withEmail: email, link: password)
    //
    //        user?.reauthenticate(with: credential) { result, err in
    //            if let err {
    //                print(err.localizedDescription)
    //            }
    //            print(result)
    //        }
    //    }
    //
    //    func sendUserEmailVerification() {
    //        Auth.auth().currentUser?.sendEmailVerification() { err in
    //            if let err {
    //                print(err.localizedDescription)
    //            }
    //        }
    //    }
    //
    //    func setUserPassword() {
    //        Auth.auth().currentUser?.updatePassword(to: password) { err in
    //            if let err {
    //                print(err.localizedDescription)
    //            }
    //        }
    //    }
    //
    //    func sendPasswordResetEmail() {
    //        Auth.auth().sendPasswordReset(withEmail: "amber@example.com") { err in
    //            if let err {
    //                print(err.localizedDescription)
    //            }
    //        }
    //    }
}
