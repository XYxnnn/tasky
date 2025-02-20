//
//  ProjectViewModel.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/15.
//

import Foundation

@MainActor
final class ProjectViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var tasksCompleted: Int = 0
    @Published var totalTasks: Int = 0
    @Published var isLoading: Bool = false // 加载状态
    @Published var errorMessage: String? = nil // 错误信息
    
    @Published var projects: [ProjectModel] = []
    
    private let projectManager: ProjectManager
    private let userID: String // 当前用户 ID
    
    
    private var manager = ProjectManager()
    // @Published var filteredProjects: [ProjectModel] = []
    
    init(projectManager: ProjectManager, userID: String) {
        self.projectManager = projectManager
        self.userID = userID
    }
    
    func createProject() async throws {
        guard !name.isEmpty else { throw ProjectError.emptyTitle }
        let newProject = ProjectModel(
            name: name,
            description: description,
            ownerID: userID // 使用当前用户的 ID
        )
        try await projectManager.addProject(newProject)
    }
    
    func updateProject(project: ProjectModel) async throws {
        guard !name.isEmpty else { throw ProjectError.emptyTitle }
        var updatedProject = project
        updatedProject.name = name
        updatedProject.description = description
        try await projectManager.updateProject(updatedProject)
    }
    
}

enum ProjectError: Error {
    case emptyTitle
    case emptyDescription
}

