//
//  UserModel.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/21.
//

import Foundation
import FirebaseFirestoreSwift

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String? 
    var name: String
    let email: String
    var phone: String?
    var location: String?
    let createdAt: Date
    var profilePictureUrl: String?
    
    init(
        name: String,
        email: String,
        phone: String? = nil,
        location: String? = nil,
        createdAt: Date = Date(),
        profilePictureUrl: String? = nil
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.location = location
        self.createdAt = createdAt
        self.profilePictureUrl = profilePictureUrl
    }
}
