//
//  LoginViewModel.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/15.
//

import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
final class LoginViewModel : ObservableObject {
    @Published var alertMsg: String = ""
    @Published var showAlert: Bool = false
    
    @Published var email = ""
    @Published var password = ""
    @Published var resetEmail = ""
    @Published var isLinkSent = false
    @Published var errorMessage: String = ""
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        
        do {
            let authResult = try await AuthenticationManager.shared.signInUser(email: email, password: password)
            
            let userID = authResult.uid
            print("Login successful. User ID: \(userID)")
            
        } catch {
            errorMessage = handleAuthError(error)
            showAlert = true
            print("Login failed: \(errorMessage)")
        }
    }
    
    func resetPassword() {
        guard !resetEmail.isEmpty else {
            alertMsg = "Please enter your email."
            showAlert = true
            return
        }

        Task {
            do {
                try await AuthenticationManager.shared.sendPasswordReset(email: resetEmail)
                alertMsg = "Password reset link has been sent to \(resetEmail)."
                isLinkSent = true
            } catch {
                alertMsg = error.localizedDescription
            }
            showAlert = true
        }
    }
    func signOut() throws {
        try AuthenticationManager.shared.logOut()
    }
    
    private func handleAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please try again later."
        case AuthErrorCode.userNotFound.rawValue:
            return "No user found with this email address."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        default:
            return "The email or password is wrong. Please try again."
        }
    }
    
}
