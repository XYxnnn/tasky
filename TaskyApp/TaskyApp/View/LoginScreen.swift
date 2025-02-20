//
//  LoginScreen.swift
//  Tasky
//
//  Created by 许昱萱 on 2024/12/8.
//

import SwiftUI

struct LoginScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    @State private var showResetPasswordView = false
    @State private var isPresentingRegisterScreen = false
    
    @StateObject var viewModel = LoginViewModel()
    @State private var isPasswordVisible: Bool = false
    

    var body: some View {
        NavigationView{
            VStack(spacing: 20) {

                Spacer()

                // Title
                Text("Welcome back!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.bottom, 20)

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
                
                // Spacer()

                Button(action: {
                    Task {
                        do {
                            try await viewModel.signIn()
                            print("User logged in.")
                        } catch {
                            print("Login failed: \(error)")
                        }
                    }
                }) {
                    Text("Login")
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

                // Forget Password
                HStack {
                    Spacer()
                    Button(action: {
                        showResetPasswordView = true
                    }) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 20)
                }

                Spacer()

                // Sign Up
                HStack {
                    Text("Don't have an account?")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Button(action: {
                        isPresentingRegisterScreen.toggle()
                    }) {
                        Text("Register Now")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .fullScreenCover(isPresented: $isPresentingRegisterScreen) {
                                RegisterScreen()
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
                appState.showLoginScreen = false
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .bold))
                    .padding()
            })
            .sheet(isPresented: $showResetPasswordView) {
                    ResetPasswordView()
            }
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}

struct ResetPasswordView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            Text("Reset Password")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 20)

            // Email
            VStack(alignment: .leading) {
                TextField("Enter your email", text: $viewModel.resetEmail)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 25)
            
            Button(action: {
                viewModel.resetPassword()
            }) {
                Text("Send Reset Link")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 25)
            .padding(.top, 30)
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Password Reset"), message: Text(viewModel.alertMsg), dismissButton: .default(Text("OK")))
        }
    }
}
