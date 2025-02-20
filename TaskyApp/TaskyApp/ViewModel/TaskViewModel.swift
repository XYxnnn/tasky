//
//  TaskManager.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/14.
//

import Foundation
import FirebaseFirestore

@MainActor
final class TaskViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var priority: String = "Normal"
    @Published var startDate: Date = Date()
    @Published var dueDate: Date = Date()
    @Published var tags: [String] = []
    @Published var isCompleted: Bool = false
    @Published var selectedProjectID: String? = nil
    
    @Published var tasks: [TaskModel] = []
    
    private let taskManager: TaskManager
    private let userID: String

    init(taskManager: TaskManager, userID: String) {
        self.taskManager = taskManager
        // self.projectManager = projectManager
        self.userID = userID
    }
    
    func createTask() async throws {
        guard !title.isEmpty else { throw TaskError.emptyTitle }

        if priority == "Select Priority" || priority.isEmpty {
            priority = "Low Priority"
        }
        
        let newTask = TaskModel(
            title: title,
            description: description,
            priority: priority,
            startDate: startDate,
            dueDate: dueDate,
            tags: tags,
            isCompleted: isCompleted,
            projectID: selectedProjectID,
            ownerID: userID
        )
        try await taskManager.addTask(newTask)
    }

    func updateTask(task: TaskModel) async throws {

        do {
            try await taskManager.updateTask(task)
            print("Task updated successfully in Firestore.")
            

            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = task
                print("Task updated successfully in local cache.")
            } else {
                print("Task not found in local cache.")
            }
        } catch {
            print("Error updating task: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteTask(taskID: String) async throws {
        do {
            // Call TaskManager's deleteTask function to delete from Firestore
            try await taskManager.deleteTask(taskID: taskID)
            
            // Remove the task locally if it exists in the array
            if let index = tasks.firstIndex(where: { $0.id == taskID }) {
                tasks.remove(at: index)
                print("Task removed from local list.")
            }
        } catch {
            // Handle error during deletion
            print("Error deleting task: \(error.localizedDescription)")
            throw error
        }
    }

    
    func markTaskAsCompleted(taskID: String) async throws {
        // guard let userID = self.userID else { throw NSError(domain: "UserID not found", code: -1, userInfo: nil) }
        
        let taskRef = Firestore.firestore().collection("tasks").document(taskID)
        try await taskRef.updateData(["isCompleted": true])
    }


}

enum TaskError: Error {
    case emptyTitle
    case emptyDescription
}
