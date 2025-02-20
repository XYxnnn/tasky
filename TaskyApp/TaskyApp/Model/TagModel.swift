//
//  TaskModel.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/14.
//

import Foundation

struct TagModel: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var description: String?
    var ownerID: String

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String? = nil,
        ownerID: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.ownerID = ownerID
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "description": description,
            "ownerID": ownerID
        ]
    }

}

