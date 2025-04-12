//
//  AuthView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI

struct AuthView: View {
    @Environment(AppController.self) private var appController
    
    @State private var isSignUp = false
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("Email", text: Bindable(appController).email)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: Bindable(appController).password)
                .textFieldStyle(.roundedBorder)
            
            Button {
                authenticate()
            } label: {
                HStack {
                    Spacer()
                    Text("\(isSignUp ? "Sign Up" : "Sign In")")
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("\(isSignUp ? "I already have an account" : "I don't have an account")") {
                isSignUp.toggle()
            }
            .padding(.top)

        }
        .padding()
    }
    
    func authenticate() {
        isSignUp ? signUp() : signIn()
    }
    
    func signUp() {
        Task {
            do {
                try await appController.signUp()
                try await appController.createUserProfile()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signIn() {
        Task {
            do {
                try await appController.signIn()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    AuthView()
}
