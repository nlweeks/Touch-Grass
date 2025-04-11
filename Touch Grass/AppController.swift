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
class AppController {
    
    var email = ""
    var password = ""
    
    var authState: AuthState = .undefined
    
    func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { auth, user in
            self.authState = user != nil ? .authenticated : .notAuthenticated
        }
    }
    
    func signUp() async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signIn() async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getUserProfile() async throws {
        let user = Auth.auth().currentUser
        
        if let user {
            let uid = user.uid
            let email = user.email ?? "amber@example.com"
            let photoURL = user.photoURL
            let userProfile = Profile(uid: uid, email: email, photoURL: photoURL)
            try await FirestoreContext.create(userProfile, collectionPath: "profiles")
        }
    }
    
    func updateUserProfile() {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = "Amber"
        changeRequest?.commitChanges { err in
            if let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func setUserEmail() {
        Auth.auth().currentUser?.updateEmail(to: "amber@example.com") { err in
            if let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func reAuthenticate() {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, link: password)
        
        user?.reauthenticate(with: credential) { result, err in
            if let err {
                print(err.localizedDescription)
            }
            print(result)
        }
    }
    
    func sendUserEmailVerification() {
        Auth.auth().currentUser?.sendEmailVerification() { err in
            if let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func setUserPassword() {
        Auth.auth().currentUser?.updatePassword(to: password) { err in
            if let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func sendPasswordResetEmail() {
        Auth.auth().sendPasswordReset(withEmail: "amber@example.com") { err in
            if let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func deleteUser() {
        let user = Auth.auth().currentUser
        
        user?.delete { err in
            if let err {
                print(err.localizedDescription)
            }
        }
    }
}
