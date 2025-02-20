//
//  ProjectModel.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/15.
//

import Foundation

struct ProjectModel: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var description: String
    var tasksCompleted: Int
    var totalTasks: Int
    var ownerID: String
    let createdAt: Date
    
    var progress: Double {
        guard totalTasks > 0 else { return 0.0 }
        return Double(tasksCompleted) / Double(totalTasks)
    }

    var isCompleted: Bool {
        tasksCompleted == totalTasks && totalTasks > 0
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        tasksCompleted: Int = 0,
        totalTasks: Int = 0,
        ownerID: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.tasksCompleted = tasksCompleted
        self.totalTasks = totalTasks
        self.ownerID = ownerID
        self.createdAt = createdAt
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "description": description,
            "tasksCompleted": tasksCompleted,
            "totalTasks": totalTasks,
            "ownerID": ownerID,
            "createdAt": createdAt
        ]
    }
}
