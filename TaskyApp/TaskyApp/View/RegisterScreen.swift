//
//  RegisterScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/12/8.
//

import SwiftUI

struct RegisterScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = RegisterViewModel()
    
    @State private var isPasswordVisible: Bool = false
    
    @State private var isPresentingLoginScreen = false
    @State private var isPresentingIntroScreen = false
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                Spacer()

                // Title
                Text("Create an account!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                // Username
                VStack(alignment: .leading) {
                    TextField("Enter your username", text: $viewModel.name)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 25)
                
                // Email
                VStack(alignment: .leading) {
                    TextField("Enter your email", text: $viewModel.email)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 25)

                // Password
                VStack(alignment: .leading) {
                    HStack {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $viewModel.password)
                                .multilineTextAlignment(.leading)
                        } else {
                            SecureField("Enter your password", text: $viewModel.password)
                                .multilineTextAlignment(.leading)
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 25)

                // Sign Up Button
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signUp()
                            print("User registered.")
                        } catch {
                            print("Registration failed: \(error)")
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 25)
                .padding(.top, 30)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()

                // Login
                HStack {
                    Text("Already have an account?")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Button(action: {
                        isPresentingLoginScreen.toggle()
                    }) {
                        Text("Login Now")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .fullScreenCover(isPresented: $isPresentingLoginScreen) {
                                LoginScreen()
                            }
                    }
                }
                .padding(.bottom, 20)
                
                Spacer()
            }
            .background(Color.white)
            .ignoresSafeArea()
            .padding()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                appState.showRegisterScreen = false
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .bold))
                    .padding()
            })
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct RegisterScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterScreen()
    }
}
