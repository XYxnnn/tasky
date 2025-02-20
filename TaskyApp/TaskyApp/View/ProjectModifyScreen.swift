//
//  TaskModifyScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/12/19.
//

import SwiftUI

struct ProjectModifyScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @StateObject private var projectViewModel: ProjectViewModel
    @StateObject private var projectManager: ProjectManager
    @EnvironmentObject var appState: AppState

    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let userID: String
    let project: ProjectModel

    init(projectManager: ProjectManager, userID: String, project: ProjectModel) {
        self.userID = userID
        self.project = project
        _projectViewModel = StateObject(wrappedValue: ProjectViewModel(projectManager: projectManager, userID: userID))
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
                    TextField("Please enter the task title", text: $projectViewModel.name)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10)
                    
                    // Description
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.black)
                    TextField("Please enter the description", text: $projectViewModel.description)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10)
                    
                    // Modify Task Button
                    Button(action: {
                        if projectViewModel.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            alertMessage = "Project name cannot be empty."
                            showAlert = true
                        }
                        else {
                            Task {
                                do {
                                    // Call the update function with the updated task
                                    try await projectViewModel.updateProject(project: project)
                                    print("Project modified successfully!")
                                    dismiss()
                                } catch {
                                    print("Error modifying project: \(error)")
                                    alertMessage = "Failed to modify project. Please try again."
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
            .navigationBarTitle("Modify Project", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Modify Project")
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
                projectManager.fetchProjects(for: userID)
                projectViewModel.name = project.name
                projectViewModel.description = project.description
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Please enter the project name."), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct ProjectModifyScreen_Previews: PreviewProvider {
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
        let mockProjectManager = ProjectManager()

        ProjectModifyScreen(projectManager: mockProjectManager, userID: "mLvdMwu6PQWtOEah1ijFezCgRfs1", project: exampleProject)
    }
}
