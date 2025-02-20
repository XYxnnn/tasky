//
//  AuthenticationManager.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/11.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AuthDataResultModel {
    let uid: String
    let email: String?
    // let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private let db = Firestore.firestore()
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func fetchUserInfo(for userID: String) async throws -> UserModel {
        let userDoc = try await db.collection("users").document(userID).getDocument()
        
        guard let user = try? userDoc.data(as: UserModel.self) else {
            throw URLError(.badServerResponse)
        }
        return user
    }
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func logOut() throws {
        try Auth.auth().signOut()
    }
    
}
