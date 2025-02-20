//
//  TaskCreateScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/11/27.
//

import SwiftUI

struct ProjectCreateScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @StateObject private var projectViewModel: ProjectViewModel
    @EnvironmentObject var appState: AppState
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let userID: String
    
    init(projectManager: ProjectManager, userID: String) {
        self.userID = userID
        _projectViewModel = StateObject(wrappedValue: ProjectViewModel(projectManager: projectManager, userID: userID))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("Name")
                        .font(.headline)
                        .foregroundColor(.black)
                    TextField("Please enter the project name", text: $projectViewModel.name)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    
                    // Description
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.black)
                    TextField("Please enter the project description", text: $projectViewModel.description)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                    
                    // Create Project Button
                    Button(action: {
                        if projectViewModel.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            alertMessage = "Project name cannot be empty."
                            showAlert = true
                        }
                        else {
                            Task {
                                do {
                                    try await projectViewModel.createProject()
                                    print("Project created successfully!")
                                    dismiss()
                                } catch {
                                    print("Error creating task: \(error)")
                                }
                            }
                        }
                    }) {
                        Text("Create a new project")
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
            .navigationBarTitle("Create Project", displayMode: .inline)
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Please enter the project name."), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    
    private func createProject() {
        // Handle the task creation logic
        print("Project Created: \(projectViewModel.name)")
        print("Description: \(projectViewModel.description)")
    }
}

struct ProjectCreateScreen_Previews: PreviewProvider {
    static var previews: some View {
        let mockProjectManager = ProjectManager()

        ProjectCreateScreen(projectManager: mockProjectManager, userID: "")
    }
}

