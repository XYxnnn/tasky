//
//  ProfileScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/11/26.
//

import SwiftUI

struct ProfileScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel = LoginViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    @State private var isEditingProfile = false
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Top Section: Profile Picture and Name
                VStack(spacing: 15) {
                    // Profile Picture
                    AsyncImage(url: URL(string: profileViewModel.user?.profilePictureUrl ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 100, height: 100)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    VStack(spacing: 5) {
                        Text(profileViewModel.user?.name ?? "Anonymous")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(profileViewModel.user?.email ?? "No Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Task Status
                    HStack {
                        TaskStatusView(title: "Task Pending", value: profileViewModel.taskPendingCount)
                        Divider()
                            .frame(height: 40)
                            .padding(.horizontal, 10)
                        TaskStatusView(title: "Task Done", value: profileViewModel.taskDoneCount)
                    }
                }
                
                ScrollView {
                    // Info Cards
                    VStack(spacing: 15) {
                        InfoRow(icon: "envelope", title: "Email", value: profileViewModel.user?.email ?? "Not Set")
                        InfoRow(icon: "clock", title: "Local Time", value: formattedDate(Date()))
                        InfoRow(icon: "phone", title: "Phone", value: profileViewModel.user?.phone ?? "Not Set")
                        InfoRow(icon: "mappin.circle", title: "Location", value: profileViewModel.user?.location ?? "Not Set")
                    }
                    
                    // Edit Button
                    Button(action: {
                        // Edit profile button action
                        isEditingProfile = true
                    }) {
                        Text("Edit profile")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding()
                    Spacer()
                }
            }
            .padding()
            .navigationBarTitle("Profile", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Sign Out", role: .destructive) {
                            Task {
                                do {
                                    try viewModel.signOut()
                                    appState.logOut()
                                } catch {
                                    
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        await profileViewModel.loadUserProfile()
                        let user = try AuthenticationManager.shared.getAuthenticatedUser()
                        await profileViewModel.loadUserTaskStatus(userID: user.uid)
                    } catch {
                        print("Failed to get authenticated user or load tasks: \(error)")
                    }
                }
            }
            .navigationDestination(isPresented: $isEditingProfile) {
                ProfileModifyScreen(profileViewModel: profileViewModel).navigationBarBackButtonHidden(true)
            }

        }
        .padding(.horizontal, 10)
    }
}

// TaskStatusView Component
struct TaskStatusView: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// InfoRow Component
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Preview
struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
    }
}
