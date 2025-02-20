//
//  TaskModifyScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/12/19.
//

import SwiftUI

struct TaskModifyScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @StateObject private var taskViewModel: TaskViewModel
    @StateObject private var projectManager: ProjectManager
    @EnvironmentObject var appState: AppState
    
    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var dueDate: Date
    @State private var selectedPriority: String
    @State private var showPriorityOptions: Bool = false
    @State private var selectedPriorityColor: Color
    @State private var selectedTags: [String]
    @State private var selectedProjectID: String? = nil
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let userID: String
    let task: TaskModel

    let priorities = ["High Priority", "Medium Priority", "Low Priority"]
    let tags = ["Academic", "Work", "Personal", "Health", "Finance", "Other"]

    init(taskManager: TaskManager, projectManager: ProjectManager, userID: String, task: TaskModel) {
        self.userID = userID
        self.task = task
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description ?? "")
        _startDate = State(initialValue: task.startDate)
        _dueDate = State(initialValue: task.dueDate)
        
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(taskManager: taskManager, userID: userID))
        _projectManager = StateObject(wrappedValue: projectManager)
        _selectedPriority = State(initialValue: task.priority ?? "Select Priority")
        _selectedPriorityColor = State(initialValue: TaskModifyScreen.getPriorityColor(priority: task.priority))
        _selectedTags = State(initialValue: task.tags ?? [])
        _selectedProjectID = State(initialValue: task.projectID)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("Title")
                        .font(.headline)
                        .foregroundColor(.black)
                    TextField("Please enter the task title", text: $title)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .multilineTextAlignment(.leading)
                        .cornerRadius(10)
                    
                    // Start Date
                    Text("Start Date")
                        .font(.headline)
                        .foregroundColor(.black)
                    HStack {
                        DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .padding(.vertical, 10)
                            .padding(.horizontal, 13)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    
                    // Due Date
                    Text("Due Date")
                        .font(.headline)
                        .foregroundColor(.black)
                    HStack {
                        DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .padding(.vertical, 10)
                            .padding(.horizontal, 13)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    
                    // Priority
                    Text("Priority Type")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            showPriorityOptions.toggle()
                        }) {
                            HStack {
                                Text(selectedPriority)
                                    .foregroundColor(selectedPriorityColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        if showPriorityOptions {
                            ForEach(priorities, id: \.self) { priority in
                                Button(action: {
                                    selectedPriority = priority
                                    selectedPriorityColor = TaskModifyScreen.getPriorityColor(priority: priority)
                                    taskViewModel.priority = priority
                                    showPriorityOptions = false
                                }) {
                                    Text(priority)
                                        .foregroundColor(TaskModifyScreen.getPriorityColor(priority: priority))
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                    
                    
                    // Add Project
                    Text("Add Project")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack (spacing: 20) {
                        Picker("Select Project", selection: $selectedProjectID) {
                            Text("None").tag(nil as String?)
                                .frame(alignment: .leading)
                                .foregroundColor(.black)
                            ForEach(projectManager.projects) { project in
                                Text(project.name).tag(project.id as String?)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 13)
                            .pickerStyle(MenuPickerStyle())
                        }
                        .onChange(of: selectedProjectID) { newValue in
                            print("On Change: Selected Project ID: \(newValue ?? "None")")
                            taskViewModel.selectedProjectID = newValue
                            
                            if let projectID = newValue,
                               let projectName = projectManager.projects.first(where: { $0.id == projectID })?.name {
                                print("Resolved Project Name: \(projectName)")
                            } else {
                                print("Error: No matching project found for ID: \(newValue ?? "None")")
                            }
                            
                            if let selectedID = selectedProjectID {
                                if !projectManager.projects.contains(where: { $0.id == selectedID }) {
                                    print("Picker Error: Selected Project ID is invalid: \(selectedID)")
                                }
                            }

                        }
                        .frame(maxWidth: 500, maxHeight: 30)
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    
                    // Add Tags
                    Text("Add Tag")
                        .font(.headline)
                        .foregroundColor(.black)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(tags, id: \.self) { tag in
                            Button(action: {
                                toggleTagSelection(tag: tag)
                            }) {
                                Text(tag)
                                    .font(.subheadline)
                                    .foregroundColor(selectedTags.contains(tag) ? .white : .black)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedTags.contains(tag) ? Color.blue : Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Description
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.black)
                    TextField("Please enter the description", text: $description)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10)
                    
                    // Modify Task Button
                    Button(action: {
                        if title.trimmingCharacters(in: .whitespaces).isEmpty {
                            alertMessage = "Task title cannot be empty."
                            showAlert = true
                        }
                        else {
                            Task {
                                do {
                                    let updatedTask = TaskModel(
                                        id: task.id,
                                        title: title,
                                        description: description.isEmpty ? nil : description,
                                        priority: selectedPriority ?? "Low Priority",
                                        startDate: startDate,
                                        dueDate: dueDate,
                                        tags: selectedTags,
                                        isCompleted: task.isCompleted,
                                        createdAt: task.createdAt,
                                        projectID: (selectedProjectID?.isEmpty == false) ? selectedProjectID : nil,
                                        ownerID: task.ownerID
                                    )
                                    print("Updating task:")
                                    print("Task ID: \(updatedTask.id)")
                                    print("Project ID: \(updatedTask.projectID ?? "nil")")
                                    print("Task data: \(updatedTask)")
                                    print("Updating task with projectId: \(updatedTask.projectID)")

                                    // Call the update function with the updated task
                                    try await taskViewModel.updateTask(task: updatedTask)
                                    print("Task modified successfully!")
                                    dismiss()
                                } catch {
                                    print("Error modifying task: \(error)")
                                    alertMessage = "Failed to modify task. Please try again."
                                    showAlert = true
                                }
                            }
                        }
                    }) {
                        Text("Save Changes")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationBarTitle("Modify Task", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Modify Task")
                        // .font(.title2)
                        // .fontWeight(.bold)
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
            }
            .onAppear {
                // projectManager.loadProjectNames()
                projectManager.fetchProjects(for: userID)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Please enter the task title."), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func toggleTagSelection(tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
    
    static func getPriorityColor(priority: String?) -> Color {
        switch priority {
        case "High Priority": return .red
        case "Medium Priority": return .orange
        case "Low Priority": return .green
        default: return .black
        }
    }
}

struct TaskModifyScreen_Previews: PreviewProvider {
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
        let mockTaskManager = TaskManager()
        let mockProjectManager = ProjectManager()

        TaskModifyScreen(taskManager: mockTaskManager, projectManager: mockProjectManager, userID: "mLvdMwu6PQWtOEah1ijFezCgRfs1", task: exampleTask)
    }
}
