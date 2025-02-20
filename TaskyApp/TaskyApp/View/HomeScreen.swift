//
//  HomeScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/11/24.
//

import SwiftUI
import FirebaseAuth

struct HomeScreen: View {
    
    @StateObject private var taskManager = TaskManager()
    @StateObject private var taskViewModel: TaskViewModel
    
    @StateObject private var projectManager = ProjectManager()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    @State private var selectedFilter: TaskFilter = .all
    @State private var searchText: String = ""
    
    @State private var today = Date()
    @State private var isPresentingTaskCreate = false
    
    let userID: String
    
    init(userID: String) {
        let manager = TaskManager()
        self.userID = userID
        _taskManager = StateObject(wrappedValue: manager)
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(taskManager: manager, userID: userID))
    }
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case high = "High Priority"
    }
    
    var filteredTasks: [TaskModel] {
        let tasks = taskManager.tasks
        // Firlter by task name in search bar
        let searchFilteredTasks = searchText.isEmpty ? tasks : tasks.filter { task in
            task.title.lowercased().contains(searchText.lowercased())
        }
        
        switch selectedFilter {
        case .all:
            return searchFilteredTasks
        case .today:
            return searchFilteredTasks.filter { Calendar.current.isDateInToday($0.dueDate) }
        case .high:
            return searchFilteredTasks.filter {
                $0.priority.lowercased() == "high priority".lowercased()
            }
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
                        TextField("Find your task", text: $searchText)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Today's Task Title
                    Text("Task List")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Task Filters
                    HStack {
                        filterButton(title: "All", filter: .all)
                        filterButton(title: "Today", filter: .today)
                        filterButton(title: "High Priority", filter: .high)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Task Card View
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Display tasks
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
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                }
                // Add Task Button
                Button(action: {
                    // Navigate to TaskCreateScreen
                    isPresentingTaskCreate.toggle()
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                    .padding(.trailing, 10)
                    .padding(.bottom, 20)
                // .padding()
                .fullScreenCover(isPresented: $isPresentingTaskCreate) {
                    TaskCreateScreen(taskManager: taskManager, projectManager: projectManager, userID: userID)
                }
            }
            .navigationBarHidden(true)
            .navigationTitle("Home")
            .padding(.horizontal, 10)
            .onAppear {
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
    func filterButton(title: String, filter: TaskFilter) -> some View {
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

// Task Card Component
struct TaskCard: View {
    var title: String
    var isCompleted: Bool
    var category: String
    var time: String
    var priority: String
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                if isCompleted == false {
                    Text("On Progress")
                        .font(.caption)
                        .padding(3)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(5)
                }
                else {
                    Text("Completed")
                        .font(.caption)
                        .padding(3)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.gray)
                        .cornerRadius(5)
                }
            }
            Text(category)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text(time)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                Spacer()
                Text(priority)
                    .font(.caption)
                    .padding(8)
                    .background(
                        priority == "High Priority" ? Color.red.opacity(0.2) :
                        priority == "Medium Priority" ? Color.orange.opacity(0.2) :
                        Color.green.opacity(0.2) // Low Priority
                    )
                    .foregroundColor(
                        priority == "High Priority" ? .red :
                        priority == "Medium Priority" ? .orange :
                        .green // Low Priority
                    )
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

// Preview
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(userID: "previewUserID")
    }
}

