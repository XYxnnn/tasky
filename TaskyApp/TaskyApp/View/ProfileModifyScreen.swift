//
//  ProfileModifyScreen.swift
//  TaskyApp
//
//  Created by 许昱萱 on 2024/12/21.
//

import SwiftUI
import PhotosUI
import UIKit

struct ProfileModifyScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State private var newName: String = ""
    @State private var newPhone: String = ""
    @State private var newLocation: String = ""
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isUploading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .center) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        } else if let profilePictureUrl = profileViewModel.user?.profilePictureUrl,
                                  let url = URL(string: profilePictureUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                case .failure:
                                    Image(systemName: "person.crop.circle.badge.xmark")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }

                        Button(action: {
                            isImagePickerPresented = true // 打开图片选择器
                        }) {
                            Text("Change Profile Picture")
                        }.padding(.top, 5)
                    }
                    
                    
                    // Username
                    Text("Username")
                        .font(.headline)
                        .foregroundColor(.black)
                    TextField("Please enter your username", text: $newName)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    
                    // Phone Number
                    Text("Phone Number")
                        .font(.headline)
                        .foregroundColor(.black)
                    TextField("Please enter your phone number", text: $newPhone)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    
                    // Location
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(.black)
                    TextField("Please enter your location", text: $newLocation)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    
                    // Modify Profile Button
                    Button(action: {
                        saveChanges()
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
            .navigationBarTitle("Modify Profile", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Modify Profile")
                        // .font(.title2)
                        // .fontWeight(.bold)
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .bold))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Back Button
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
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onAppear {
                // Populate existing values
                newName = profileViewModel.user?.name ?? ""
                newPhone = profileViewModel.user?.phone ?? ""
                newLocation = profileViewModel.user?.location ?? ""
            }
        }
    }
    
    func saveChanges() {
        Task {
            do {
                try await profileViewModel.updateUserProfile(name: newName, phone: newPhone, location: newLocation)
                
                if let selectedImage = selectedImage {
                    isUploading = true
                    _ = try await profileViewModel.uploadProfilePicture(image: selectedImage)
                    isUploading = false
                }
                
                presentationMode.wrappedValue.dismiss() // Close the sheet after saving
            } catch {
                print("Failed to update profile: \(error)")
                isUploading = false
            }
        }
    }
}
