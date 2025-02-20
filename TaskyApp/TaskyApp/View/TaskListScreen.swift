//
//  TaskListScreen.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/18.
//


import SwiftUI

struct TaskListScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let userID: String
    let projectID: String
    let project: ProjectModel
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var projectManager: ProjectManager
    @State private var isPresentingProjectModify = false
    @State private var showConfirmationDialog = false
    
    
    var filteredTasks: [TaskModel] {
        taskManager.filterTasksByProject(for: projectID)
    }
    
    
    var body: some View {
        NavigationStack() {
            
            ScrollView {
                if filteredTasks.isEmpty {
                    Text("No tasks for this project!")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                LazyVStack(spacing: 15) {
                    ForEach(filteredTasks) { task in
                        NavigationLink(
                            destination: TaskDetailScreen(userID: userID, task: task, taskManager: taskManager).navigationBarBackButtonHidden(true)
                        ) {
                            TaskCard(
                                title: task.title,
                                isCompleted: task.isCompleted,
                                category: task.tags.joined(separator: ", "), // Join tags into a single string
                                time: formattedDate(task.dueDate),
                                priority: task.priority
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Project Task List", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(project.name)
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .bold))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding(.horizontal, 7)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProjectDetailToolbar(isPresentingProjectModify: $isPresentingProjectModify, projectManager: projectManager, projectID: project.id)
                }
            }
            .navigationDestination(isPresented: $isPresentingProjectModify) {
                ProjectModifyScreen(
                    projectManager: projectManager,
                    userID: userID,
                    project: project
                ).navigationBarBackButtonHidden(true)
            }
        }
        .padding()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ProjectDetailToolbar: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresentingProjectModify: Bool
    @State private var showConfirmationDialog = false
    @ObservedObject var projectManager: ProjectManager
    var projectID: String
    
    var body: some View {
        Menu {
            Button("Modify Project") {
                isPresentingProjectModify = true
            }
            Button("Delete Project", role: .destructive) {
                showConfirmationDialog = true
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
                .foregroundColor(.gray)
        }
        .confirmationDialog("Are you sure you want to delete this project?", isPresented: $showConfirmationDialog) {
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        // Delete project
                        try await projectManager.deleteProject(projectID)
                        print("Project deleted successfully.")
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Error deleting project: \(error.localizedDescription)")
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}


struct TaskListScreen_Previews: PreviewProvider {
    static var previews: some View {
        let exampleProject = ProjectModel(
            id: UUID().uuidString,
            name: "NFT Web App Prototype",
            description: "Last year was a fantastic year for NFTs, with the market reaching $40 billion.",
            tasksCompleted: 7,
            totalTasks: 10,
            ownerID: "xxx",
            createdAt: Date()
        )
        // let exampleProjectID = UUID().uuidString
        let mockTaskManager = TaskManager()
        let mockProjectManager = ProjectManager()
        TaskListScreen(userID: "", projectID: exampleProject.id, project: exampleProject, taskManager: mockTaskManager, projectManager: mockProjectManager)
    }
}
