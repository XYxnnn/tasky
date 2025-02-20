//
//  TaskCreateScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/11/27.
//

import SwiftUI

struct TaskDetailScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    let task: TaskModel
    @StateObject private var taskManager = TaskManager()
    @StateObject private var projectManager = ProjectManager()
    
    
    @State private var isTaskCompleted = false
    
    @State private var isPresentingTaskModify = false
    
    @State private var showConfirmationDialog = false
    
    let userID: String

    @StateObject private var taskViewModel: TaskViewModel
    
    init (userID: String, task: TaskModel, taskManager: TaskManager) {
        self.userID = userID
        self.task = task
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(taskManager: taskManager, userID: userID))
    }
    
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a, dd MMM yyyy"
        return formatter
    }
    
    private func priorityColor(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "high priority": return .red
        case "medium priority": return .orange
        default: return .green
        }
    }
    
    private func statusColor(_ isCompleted: Bool) -> Color {
        switch isCompleted {
            case true: return .green
            case false: return .orange
        }
    }
    
    private func markTaskAsDone() async {
        do {
            try await taskViewModel.markTaskAsCompleted(taskID: task.id)
            isTaskCompleted = true
        } catch {
            print("Failed to mark task as completed: \(error.localizedDescription)")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("Title")
                        .font(.headline)
                    // .font(.subheadline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    HStack {
                        Text(task.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                        if task.isCompleted == false {
                            Text("On Progress")
                                .font(.caption)
                                .padding(6)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                        else {
                            Text("Completed")
                                .font(.caption)
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.gray)
                                .cornerRadius(6)
                        }
                    }
                    
                    // Start Date
                    Text("Start Date")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        
                        // Spacer()
                        Text(dateFormatter.string(from: task.startDate))
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    
                    
                    // Due Date
                    Text("Due Date")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text(dateFormatter.string(from: task.dueDate))
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    
                    
                    Text("Priority Type")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    Text(task.priority)
                        .font(.subheadline)
                        .padding()
                        .background(priorityColor(task.priority).opacity(0.1))
                        .foregroundColor(priorityColor(task.priority))
                        .cornerRadius(10)
                    
                    // Project
                    Text("Project")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    HStack (spacing: 20) {
                        let projectName = projectManager.getProjectName(for: task.projectID)
                        Text(projectName)
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(8)
                            .padding(.horizontal, 5)
                        //.background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        Spacer()
                            .frame(maxWidth: 500, maxHeight: 30)
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    
                    
                    // Tags
                    Text("Tags")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(task.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.subheadline)
                                .foregroundColor(tag.contains(tag) ? .white : .black)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(tag.contains(tag) ? Color.blue.opacity(0.8) : Color(UIColor.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    
                    // Description
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    Text(task.description ?? "No Description for this task.")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    
                    // Mark done Button
                    Button(action: {
                        Task {
                            await markTaskAsDone()
                        }
                    }) {
                        if (task.isCompleted == true) {
                            Text("This task is already done!")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.gray)
                                .cornerRadius(10)
                        }
                        else {
                            Text("Mark this task as done!")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(task.isCompleted)
                    .padding(.top, 20)
                    
                }
                .padding()
                .padding(.horizontal, 10)
            }
            .navigationBarTitle("Task Details", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Task Details")
                        // .font(.title2)
                        // .fontWeight(.bold)
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .bold))
                }
            }
            .navigationBarBackButtonHidden(false)
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
                    TaskDetailToolbar(isPresentingTaskModify: $isPresentingTaskModify, taskViewModel: taskViewModel, taskID: task.id)
                }
            }
            .navigationDestination(isPresented: $isPresentingTaskModify) {
                TaskModifyScreen(
                    taskManager: taskManager,
                    projectManager: projectManager,
                    userID: userID,
                    task: task
                ).navigationBarBackButtonHidden(true)
            }
            .onAppear {
                // projectManager.fetchProjects(for: userID)
                Task {
                    await projectManager.loadProjectNames()
                    print("Task projectID: \(task.projectID ?? "nil")")
                    print("Project name resolved: \(projectManager.getProjectName(for: task.projectID))")
                }
            }
        }
    }

}

struct TaskDetailToolbar: View {
    @Binding var isPresentingTaskModify: Bool
    @State private var showConfirmationDialog = false
    @ObservedObject var taskViewModel: TaskViewModel
    var taskID: String
    
    var body: some View {
        Menu {
            Button("Modify Task") {
                isPresentingTaskModify = true
            }
            Button("Delete Task", role: .destructive) {
                showConfirmationDialog = true
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
                .foregroundColor(.gray)
        }
        .confirmationDialog("Are you sure you want to delete this task?", isPresented: $showConfirmationDialog) {
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await taskViewModel.deleteTask(taskID: taskID)
                        print("Task deleted successfully.")
                    } catch {
                        print("Error deleting task: \(error.localizedDescription)")
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct TaskDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let exampleTask = TaskModel(
            id: UUID().uuidString,
            title: "NFT Web App Prototype",
            description: "Last year was a fantastic year for NFTs, with the market reaching $40 billion.",
            priority: "High Priority",
            startDate: Date(),
            dueDate: Date(),
            tags: ["Academic", "Work", "Other"],
            isCompleted: false,
            createdAt: Date(),
            projectID: "Final Year Project",
            ownerID: ""
        )
        let taskManager = TaskManager()
        let projectManager = ProjectManager()
        
        let taskViewModel = TaskViewModel(taskManager: taskManager, userID: "")

        TaskDetailScreen(userID: "", task: exampleTask, taskManager: taskManager)
    }
}

