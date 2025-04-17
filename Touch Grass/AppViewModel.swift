//
//  AppController.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum AuthState {
    case undefined, authenticated, notAuthenticated
}

@Observable
class AppViewModel {
    
    // MARK: - Auth UI Inputs
    var email = ""
    var password = ""
    
    // MARK: - Firestore Profile
    var currentUserProfile: Profile?
    
    // MARK: - Auth Changes + Sync With Firestore Profile
    var authState: AuthState = .undefined
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
                self.authState = .authenticated
                self.startListeningToUserProfile(uid: user.uid)
            } else {
                self.authState = .notAuthenticated
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
        let db = Firestore.firestore()
        let docRef = db.collection("profiles").document(uid)
        
        // Remove existing listener if any
        removeProfileListener()
        
        // Perform an initial fetch
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    self.currentUserProfile = try document.data(as: Profile.self)
                } catch {
                    print("Error decoding profile: \(error)")
                }
            } else {
                print("Profile does not exist.")
            }
        }
        
        // Set up real-time listener
        profileListener = docRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            do {
                self.currentUserProfile = try document.data(as: Profile.self)
            } catch {
                print("Error decoding profile: \(error)")
            }
        }
    }
    
    private func removeProfileListener() {
        profileListener?.remove()
        profileListener = nil
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
    
    // MARK: - Firestore Profile Creation + Fetching
    func createUserProfile() async throws {
        guard let user = Auth.auth().currentUser else {
            print("No user signed in.")
            return
        }
        
        let profile = Profile(uid: user.uid, email: user.email ?? "")
        let db = Firestore.firestore()
        do {
            try db.collection("profiles").document(user.uid).setData(from: profile)
        } catch {
            print("Error writing profile to Firestore: \(error)")
        }
    }
    
    func deleteUserProfile(uid: String) {
        let db = Firestore.firestore()
        db.collection("profiles").document(uid).delete()
    }
    
    // MARK: - Firestore Auth Info Changes
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
