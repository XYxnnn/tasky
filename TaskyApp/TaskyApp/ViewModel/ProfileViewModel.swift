//
//  ProfileViewModel.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: UserModel? = nil
    @Published var loading: Bool = true
    @Published var errorMessage: String? = nil
    
    @Published var taskPendingCount: Int = 0
    @Published var taskDoneCount: Int = 0
    
    @Published var profilePictureURL: URL?
    
    private let authManager = AuthenticationManager.shared
    
    private let db = Firestore.firestore()
    
    func loadUserProfile() async {
        do {
            let authUser = try authManager.getAuthenticatedUser()
            let userID = authUser.uid
            
            let userInfo = try await authManager.fetchUserInfo(for: userID)
            self.user = userInfo
        } catch {
            self.errorMessage = "Failed to load user profile: \(error.localizedDescription)"
        }
        

        self.loading = false
    }
    
    func updateUserProfile(name: String, phone: String, location: String) async throws {
        guard let userID = try? authManager.getAuthenticatedUser().uid else {
            throw URLError(.badServerResponse)
        }
        
        let updatedData: [String: Any] = [
            "name": name,
            "phone": phone,
            "location": location
        ]
        
        try await db.collection("users").document(userID).updateData(updatedData)
        self.user?.name = name
        self.user?.phone = phone
        self.user?.location = location
    }
    
    func uploadProfilePicture(image: UIImage) async throws -> String {
        guard let userID = try? authManager.getAuthenticatedUser().uid else {
            throw URLError(.badServerResponse)
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }

        let storageRef = Storage.storage().reference().child("profile_pictures/\(userID).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        
        let downloadUrl = try await storageRef.downloadURL().absoluteString
        
        try await db.collection("users").document(userID).updateData(["profilePictureUrl": downloadUrl])
        
        self.user?.profilePictureUrl = downloadUrl
        
        return downloadUrl
    }
    
    // Load user tasks and calculate Task Pending/Done
    func loadUserTaskStatus(userID: String) async {
        do {
            let snapshot = try await db.collection("tasks")
                .whereField("ownerID", isEqualTo: userID)
                .getDocuments()
            
            let tasks = snapshot.documents.compactMap { document in
                try? document.data(as: TaskModel.self)
            }
            
            // Calculate counts
            self.taskPendingCount = tasks.filter { !$0.isCompleted }.count
            self.taskDoneCount = tasks.filter { $0.isCompleted }.count
        } catch {
            print("Failed to load tasks: \(error)")
        }
    }
    
    func loadProfilePicture(userID: String) async {
        let storageRef = Storage.storage().reference(withPath: "profile_pictures/\(userID).jpg")
        do {
            let url = try await storageRef.downloadURL()
            self.profilePictureURL = url
        } catch {
            print("Failed to load profile picture: \(error)")
            self.profilePictureURL = nil
        }
    }

}
