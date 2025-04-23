//
//  CodeScraps.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/16/25.
//

import Foundation
import SwiftUI

// MARK: Using an enum for a picker (for professions selection, for example)

//enum Sample: String, Equatable, CaseIterable {
//    case first  = "First"
//    case second = "Second"
//    case third  = "Third"
// 
//    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
//}
// 
//struct SampleView: View {
//    @State var selection: Sample = .first
//    var body: some View {
//        Form {
//            Picker("This Title Is Localized", selection: $selection) {
//                ForEach(Sample.allCases, id: \.id) { value in
//                    Text(value.localizedName)
//                        .tag(value)
//                }
//            }
//        }
//        .padding()
//    }
//}


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
