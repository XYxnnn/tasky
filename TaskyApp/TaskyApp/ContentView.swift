//
//  ContentView.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/11/26.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, projects, schedule, profile
    }
    
    var body: some View {
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            
            TabView(selection: $selectedTab) {
                
                // Home Screen
                HomeScreen(userID: userID)
                    .tabItem {
                        Image(systemName: selectedTab == .home ? "house.fill" : "house")
                        Text("Home")
                    }
                    .tag(Tab.home)
                
                // Project Screen
                ProjectScreen(userID: userID)
                    .tabItem {
                        Image(systemName: selectedTab == .projects ? "rectangle.grid.2x2.fill" : "rectangle.grid.2x2")
                        Text("Projects")
                    }
                    .tag(Tab.projects)
                
                // Schedule
                ScheduleScreen(userID: userID)
                    .tabItem {
                        Image(systemName: selectedTab == .schedule ? "calendar.circle.fill" : "calendar.circle")
                        Text("Schedule")
                    }
                    .tag(Tab.schedule)
                
                // Profile Screen
                ProfileScreen()
                    .tabItem {
                        Image(systemName: selectedTab == .profile ? "person.crop.circle.fill" : "person.crop.circle")
                        Text("Profile")
                    }
                    .tag(Tab.profile)
            }
            .accentColor(.blue)

        }
        else {
            IntroductionScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

