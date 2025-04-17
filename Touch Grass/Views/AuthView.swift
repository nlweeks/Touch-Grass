//
//  AuthView.swift
//  Touch Grass
//
//  Created by Noah Weeks on 4/11/25.
//

import SwiftUI

struct AuthView: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    @State private var isSignUp = false
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("Email", text: Bindable(appViewModel).email)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: Bindable(appViewModel).password)
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
            
            Button("\(isSignUp ? "I already have an account" : "Create an account")") {
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
                try await appViewModel.signUp()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signIn() {
        Task {
            do {
                try await appViewModel.signIn()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    AuthView()
        .environment(AppViewModel())
}
