//
//  RegisterViewModel.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/11.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class RegisterViewModel : ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    private let db = Firestore.firestore()
    
    @Published var alertMsg: String = ""
    @Published var showAlert: Bool = false
    @Published var errorMessage: String = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            print("No email or password found.")
            return
        }
        
        let authResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        
        let userID = authResult.uid
        
        let userData: [String: Any] = [
            "name": name.isEmpty ? "Anonymous" : name,
            "email": email,
            "createdAt": Timestamp(date: Date()),
        ]
        
        do {
            try await db.collection("users").document(userID).setData(userData)
            print("User data successfully written to Firestore")
        } catch {
            errorMessage = handleAuthError(error)
            showAlert = true
            print("Error writing user data to Firestore: \(error)")
            throw error
        }
        
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
