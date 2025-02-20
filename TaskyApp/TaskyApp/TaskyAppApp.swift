//
//  TaskyAppApp.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/10.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct TaskyAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var appState = AppState()
    
    @StateObject private var taskManager = TaskManager()
    @StateObject private var projectManager = ProjectManager()
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                ContentView()
            } else if appState.showRegisterScreen {
                RegisterScreen()
            } else if appState.showLoginScreen {
                LoginScreen()
            } else {
                IntroductionScreen()
            }
        }
        .environmentObject(appState) // 全局共享 appState
    }
    
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("Firebase configured successfully!")


    return true
  }
}

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userID: String? = nil
    @Published var showRegisterScreen: Bool = false
    @Published var showLoginScreen: Bool = false
    
    init() {
        listenToAuthChanges()
    }
    
    private func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            if let user = user {
                self.isLoggedIn = true
                self.userID = user.uid
            } else {
                self.isLoggedIn = false
                self.userID = nil
            }
        }
    }
    
    func logOut() {
        do {
            try AuthenticationManager.shared.logOut()
            self.isLoggedIn = false
            self.userID = nil
            self.showLoginScreen = false
            self.showRegisterScreen = false
        } catch {
            print("Failed to log out: \(error.localizedDescription)")
        }
    }
}

