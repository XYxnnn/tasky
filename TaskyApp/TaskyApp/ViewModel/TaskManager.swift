//
//  TaskManager.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/14.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class TaskManager: ObservableObject {
    @Published var tasks: [TaskModel] = []
    
    private let db = Firestore.firestore()
    private let collectionName = "tasks"
    private var cancellables = Set<AnyCancellable>()

    
    // Fetch tasks for a specific user
    func fetchTasks(for userID: String) {
        db.collection(collectionName)
            .whereField("ownerID", isEqualTo: userID) // Filter tasks by user ID
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    return
                }
                
                // Map documents to TaskModel
                self.tasks = snapshot?.documents.compactMap { document in
                    try? document.data(as: TaskModel.self)
                } ?? []
            }
    }
    
    
    func filterTasksByProject(for projectID: String) -> [TaskModel] {
        return tasks.filter { $0.projectID == projectID }
    }
     
    
    func markTaskAsCompleted(taskID: String) async {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else {
            print("Task not found")
            return
        }
        
        var updatedTask = tasks[index]
        updatedTask.isCompleted = true
        
        do {
            try await updateTask(updatedTask)
            tasks[index] = updatedTask
            print("Task marked as completed")
        } catch {
            print("Error updating task: \(error.localizedDescription)")
        }
    }
    
    // Filter tasks by date
    func fetchTasks(for date: Date) -> [TaskModel] {
        return tasks.filter { isSameDay($0.startDate, date) }
    }

    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }

    // Add a new task
    func addTask(_ task: TaskModel) async throws {
        let documentRef = db.collection(collectionName).document(task.id)
        try await documentRef.setData(task.toDictionary())
    }

    // Update an existing task
    func updateTask(_ task: TaskModel) async throws {
        let documentID = task.id
        
        let documentRef = db.collection(collectionName).document(documentID)
        
        let taskData = task.toDictionary()

        do {
            try await documentRef.updateData(taskData)
            print("Task updated successfully in Firestore.")
        } catch {
            print("Error updating task in Firestore: \(error.localizedDescription)")
            throw error
        }
    }


    // Delete a task
    
    func deleteTask(taskID: String) async throws {
        // Reference the Firestore document using the task ID
        let documentRef = db.collection(collectionName).document(taskID)
        
        do {
            // Attempt to delete the document
            try await documentRef.delete()
            print("Task with ID \(taskID) deleted successfully.")
        } catch {
            // Throw error if deletion fails
            print("Error deleting task: \(error.localizedDescription)")
            throw error
        }
    }
}
