//
//  TaskCreateScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/11/27.
//

import SwiftUI

struct TaskCreateScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @StateObject private var taskViewModel: TaskViewModel
    @StateObject private var projectManager: ProjectManager
    @EnvironmentObject var appState: AppState
    
    @State private var selectedProjectID: String? = nil
    @State private var selectedPriority: String = "Select Priority"
    @State private var showPriorityOptions: Bool = false
    @State private var selectedPriorityColor: Color = .black
    @State private var selectedTags: [String] = []
    
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let userID: String
    let priorities = ["High Priority", "Medium Priority", "Low Priority"]
    let tags = ["Academic", "Work", "Personal", "Health", "Finance", "Other"]
    
    
    init(taskManager: TaskManager, projectManager: ProjectManager, userID: String) {
        self.userID = userID
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(taskManager: taskManager, userID: userID))
        _projectManager = StateObject(wrappedValue: projectManager)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("Title")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    TextField("Please enter the task title", text: $taskViewModel.title)
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    
                    // Start Date
                    Text("Start Date")
                        .font(.headline)
                        .foregroundColor(.black)
                    HStack {
                        DatePicker("", selection: $taskViewModel.startDate, displayedComponents: [.date, .hourAndMinute])
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
                        DatePicker("", selection: $taskViewModel.dueDate, displayedComponents: [.date, .hourAndMinute])
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
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal, 20)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        if showPriorityOptions {
                            VStack(spacing: 10) {
                                // High Priority
                                Button(action: {
                                    selectedPriority = "High Priority"
                                    selectedPriorityColor = .red
                                    taskViewModel.priority = "High"
                                    showPriorityOptions = false
                                }) {
                                    Text("High Priority")
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }
                                
                                // Medium Priority
                                Button(action: {
                                    selectedPriority = "Medium Priority"
                                    selectedPriorityColor = .orange
                                    taskViewModel.priority = "Medium"
                                    showPriorityOptions = false
                                }) {
                                    Text("Medium Priority")
                                        .foregroundColor(.orange)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                }
                                
                                // Low Priority
                                Button(action: {
                                    selectedPriority = "Low Priority"
                                    selectedPriorityColor = .green
                                    taskViewModel.priority = "Low"
                                    showPriorityOptions = false
                                }) {
                                    Text("Low Priority")
                                        .foregroundColor(.green)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
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
                                .multilineTextAlignment(.leading)
                            ForEach(projectManager.projects) { project in
                                Text(project.name).tag(project.id as String?)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 13)
                            .pickerStyle(MenuPickerStyle())
                        }
                        .onChange(of: selectedProjectID) { newValue in
                            taskViewModel.selectedProjectID = newValue
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
                    TextField("Please enter the description", text: $taskViewModel.description)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    
                    // Create Task Button
                    Button(action: {
                        if taskViewModel.title.trimmingCharacters(in: .whitespaces).isEmpty {
                            alertMessage = "Task title cannot be empty."
                            showAlert = true
                        }
                        else {
                            Task {
                                do {
                                    
                                    taskViewModel.priority = selectedPriority
                                    taskViewModel.selectedProjectID = selectedProjectID
                                    taskViewModel.tags = selectedTags
                                    try await taskViewModel.createTask()
                                    print("Task created successfully!")
                                    dismiss()
                                } catch {
                                    print("Error creating task: \(error)")
                                }
                            }
                        }
                    }) {
                        Text("Create a new task")
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
            .navigationBarTitle("Create Task", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                // Back Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
            .onAppear {
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
}

struct TaskCreateScreen_Previews: PreviewProvider {
    static var previews: some View {
        let mockTaskManager = TaskManager()
        let mockProjectManager = ProjectManager()

        TaskCreateScreen(taskManager: mockTaskManager, projectManager: mockProjectManager, userID: "mLvdMwu6PQWtOEah1ijFezCgRfs1")
    }
}

