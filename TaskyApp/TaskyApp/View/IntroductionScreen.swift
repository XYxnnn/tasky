//
//  IntroductionScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/12/8.
//

import SwiftUI

struct IntroductionScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    // @Binding var showRegisterScreen: Bool
    
    @State private var isPresentingRegisterScreen = false
    @State private var isPresentingLoginScreen = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("intro_picture")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding(.top, 30)
                .padding()

            
            Text("Tasky: Manage the tasks")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.top, 10)
            
            Text("Improve Productivity And Enjoy Your Time By Managing Your Tasks!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 30)

            Spacer()
            
            // Login Button
            Button(action: {
                appState.showLoginScreen = true
            }) {
                Text("Login")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            
            // Sign Up Button
            Button(action: {
                appState.showRegisterScreen = true
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea()
    }
}

struct IntroductionScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            IntroductionScreen()
        }
    }
}

