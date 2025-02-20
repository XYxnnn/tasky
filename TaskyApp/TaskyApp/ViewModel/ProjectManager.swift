//
//  ProjectManager.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/15.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreAudioTypes

@MainActor
final class ProjectManager: ObservableObject {
    static let shared = ProjectManager()
    
    @Published var projects: [ProjectModel] = []
    @Published var tasks: [TaskModel] = []
    // private(set) var projectName: [String: String] = [:]
    @Published var projectName: [String: String] = [:]
    private let db = Firestore.firestore()
    private let collectionName = "projects"
    
    
    // Add a new task
    func addProject(_ project: ProjectModel) async throws {
        let documentRef = db.collection(collectionName).document(project.id)
        try await documentRef.setData(project.toDictionary())
    }

    // Update an existing task
    func updateProject(_ project: ProjectModel) async throws {
        guard let documentID = project.id as String? else { return }
        let documentRef = db.collection(collectionName).document(documentID)
        try await documentRef.updateData(project.toDictionary())
    }

    // Delete a task
    func deleteProject(_ projectID: String) async throws {
        let documentRef = db.collection(collectionName).document(projectID)
        try await documentRef.delete()
    }
    
    func fetchProjects(for userID: String, completion: (() -> Void)? = nil) {
        db.collection("projects")
            .whereField("ownerID", isEqualTo: userID) // Filter projects by user ID
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching projects: \(error)")
                    completion?()
                    return
                }
                
                // Map documents to ProjectModel
                self.projects = snapshot?.documents.compactMap { document in
                    try? document.data(as: ProjectModel.self)
                } ?? []
                
                // 在获取 projects 后调用 fetchTasks
                self.fetchTasks(for: userID) {
                    self.updateTaskStatistics()
                    completion?()
                }
            }
    }
    
    func fetchTasks(for userID: String, completion: (() -> Void)? = nil) {
        db.collection("tasks")
            .whereField("ownerID", isEqualTo: userID) // Filter tasks by user ID
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    completion?()
                    return
                }
                
                // Map documents to TaskModel
                self.tasks = snapshot?.documents.compactMap { document in
                    try? document.data(as: TaskModel.self)
                } ?? []
                
                completion?()
            }
    }
    
    func updateTaskStatistics() {
        for projectIndex in projects.indices {
            let projectID = projects[projectIndex].id
            
            // Filter tasks belonging to the current project
            let projectTasks = tasks.filter { $0.projectID == projectID }
            
            // Calculate completed tasks and total tasks
            let completedTasks = projectTasks.filter { $0.isCompleted }.count
            let totalTasks = projectTasks.count
            
            // Update project statistics
            projects[projectIndex].tasksCompleted = completedTasks
            projects[projectIndex].totalTasks = totalTasks
        }
    }
    
    func loadProjectNames() async {
        do {
            let snapshot = try await db.collection("projects").getDocuments()
            var tempProjectName: [String: String] = [:]
            for document in snapshot.documents {
                let id = document.documentID
                let name = document.data()["name"] as? String ?? "Unnamed Project"
                tempProjectName[id] = name
            }
            DispatchQueue.main.async {
                self.projectName = tempProjectName
                print("Project names loaded: \(self.projectName)")
            }
        } catch {
            print("Error loading project names: \(error.localizedDescription)")
        }
    }
    
    func getProjectName(for projectID: String?) -> String {
        guard let id = projectID else {
            print("Project ID is nil.")
            return "Unassigned"
        }
        guard let name = projectName[id] else {
            print("No project name found for ID: \(id)")
            return "Unknown"
        }
        return name
    }
    
    
    func getProjectsArray() -> [ProjectModel] {
        return self.projects
    }
    
    func fetchProjectsList(ownerID: String) async throws -> [ProjectModel] {
        let snapshot = try await db.collection("projects")
            .whereField("ownerID", isEqualTo: ownerID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc -> ProjectModel? in
            try? doc.data(as: ProjectModel.self)
        }
    }

}
