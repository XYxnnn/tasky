//
//  TaskModel.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/14.
//

import Foundation

struct TaskModel: Codable, Identifiable, Hashable {
    let id: String
    var title: String
    var description: String?
    var priority: String
    var startDate: Date
    var dueDate: Date
    var tags: [String]
    var isCompleted: Bool
    var createdAt: Date
    var projectID: String? // Optional
    var ownerID: String

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String? = nil,
        priority: String,
        startDate: Date,
        dueDate: Date,
        tags: [String] = [],
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        projectID: String? = nil,
        ownerID: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.startDate = startDate
        self.dueDate = dueDate
        self.tags = tags
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.projectID = projectID
        self.ownerID = ownerID
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "description": description,
            "priority": priority,
            "startDate": startDate,
            "dueDate": dueDate,
            "tags": tags,
            "isCompleted": isCompleted,
            "createdAt": createdAt,
            "projectID": projectID ?? NSNull(),
            "ownerID": ownerID
        ]
    }

}

