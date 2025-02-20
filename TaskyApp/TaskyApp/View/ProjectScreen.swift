//
//  ProjectScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/11/26.
//

import SwiftUI

struct ProjectScreen: View {
    
    @EnvironmentObject var appState: AppState
    @StateObject private var projectManager = ProjectManager()
    @StateObject private var taskManager = TaskManager()
    @StateObject var projectViewModel: ProjectViewModel
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var isPresentingProjectCreate = false
    
    @StateObject private var profileViewModel = ProfileViewModel()
    
    @State private var today = Date()
    
    @State private var selectedFilter: ProjectFilter = .all
    @State private var searchText: String = ""
    
    // let project: ProjectModel
    let userID: String
    
    init(userID: String) {
        let manager = ProjectManager()
        self.userID = userID
        _projectManager = StateObject(wrappedValue: manager)
        _projectViewModel = StateObject(wrappedValue: ProjectViewModel(projectManager: manager, userID: userID))
    }
    
    enum ProjectFilter: String, CaseIterable {
        case all = "All"
        case progress = "In-progress"
        case complete = "Completed"
    }
    
    var filteredProjects: [ProjectModel] {
        let projects = projectManager.projects
        // Firlter by task name in search bar
        let searchFilteredProjects = searchText.isEmpty ? projects : projects.filter { project in
            project.name.lowercased().contains(searchText.lowercased())
        }
        
        switch selectedFilter {
        case .all:
            return searchFilteredProjects
        case .progress:
            return searchFilteredProjects.filter { !$0.isCompleted }
        case .complete:
            return searchFilteredProjects.filter { $0.isCompleted }
        }
    }
        
    var body: some View {
        NavigationView {
            ZStack (alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Top Bar
                    HStack {
                        if let url = profileViewModel.profilePictureURL {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                                    .clipped()
                            } placeholder: {
                                ProgressView() // Placeholder while image is loading
                            }
                        } else {
                            Image("profile_picture") // Default profile picture
                                .resizable()
                                .scaledToFill()
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                                .clipped()
                        }

                    }
                    .padding(.horizontal)
                    
                    // Greeting and Date
                    VStack(alignment: .leading, spacing: 5) {
                        // Greeting
                        Text(greeting() + (profileViewModel.user?.name ?? "User"))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Date
                        Text(formattedDate(today))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Search Bar
                    HStack {
                        TextField("Find your project", text: $searchText)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Project Title
                    Text("Project")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Project Filters
                    HStack {
                        filterProject(title: "All", filter: .all)
                        filterProject(title: "In-progress", filter: .progress)
                        filterProject(title: "Completed", filter: .complete)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Project Cards View
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(filteredProjects) { project in
                                NavigationLink(
                                    destination: TaskListScreen(userID: userID, projectID: project.id, project: project, taskManager: taskManager, projectManager: projectManager).navigationBarBackButtonHidden(true)
                                ){
                                    ProjectCard(
                                        title: project.name,
                                        tasks: "\(project.tasksCompleted) of \(project.totalTasks) tasks completed",
                                        progress: Double(project.tasksCompleted) / Double(max(project.totalTasks, 1))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                }
                Button(action: {
                    // Add project action
                    isPresentingProjectCreate.toggle()
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.black)
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                    .padding(.trailing, 10)
                    .padding(.bottom, 20)
                // .padding()
                .fullScreenCover(isPresented: $isPresentingProjectCreate) {
                    ProjectCreateScreen(projectManager: projectManager, userID: userID)
                }
            }
            .navigationBarHidden(true)
            .padding(.horizontal, 10)
            .fullScreenCover(isPresented: $isPresentingProjectCreate) {
                ProjectCreateScreen(projectManager: projectManager, userID: userID)
            }
            .onAppear {
                projectManager.fetchProjects(for: userID)
                taskManager.fetchTasks(for: userID)
                Task {
                    do {
                        let user = try AuthenticationManager.shared.getAuthenticatedUser()
                        await profileViewModel.loadProfilePicture(userID: user.uid)
                        await profileViewModel.loadUserProfile()
                    } catch {
                        print("Failed to load user or profile picture: \(error)")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func filterProject(title: String, filter: ProjectFilter) -> some View {
        Text(title)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(selectedFilter == filter ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(selectedFilter == filter ? .blue : .black)
            .cornerRadius(20)
            .onTapGesture {
                withAnimation {
                    selectedFilter = filter
                }
            }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Adjust the style as needed
        return formatter.string(from: date)
    }
    
    // Greeting Function
    func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Good Morning, "
        case 12..<18:
            return "Good Afternoon, "
        case 18..<24:
            return "Good Evening, "
        default:
            return "Hello, "
        }
    }

}

// Project Card Component
struct ProjectCard: View {
    var title: String
    var tasks: String
    var progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(tasks)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 5) {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.white)
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.95), Color.purple.opacity(0.95)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

// Preview
struct ProjectScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProjectScreen(userID: "")
    }
}

