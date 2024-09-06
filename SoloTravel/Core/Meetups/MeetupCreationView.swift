//
//  MeetupCreationView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/4/24.
//

import SwiftUI

struct MeetupCreationView: View {
    
    @StateObject private var viewModel = MeetupCreationViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isImagePickerPresented = false
    var city: String?
    var country: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if let selectedImage = viewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .shadow(radius: 5)
                            .onTapGesture {
                                isImagePickerPresented.toggle()
                            }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .frame(width: 400, height: 400)
                                .foregroundStyle(Color(red: 0.95, green: 0.95, blue: 0.95))
                            
                            VStack {
                                Image(systemName: "camera.viewfinder")
                                     .font(.system(size: 75))
                                     .foregroundStyle(.gray)
                                 
                                 Text("Upload a picture for your meetup!")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .onTapGesture {
                            isImagePickerPresented.toggle()
                        }
                        .padding(.bottom)
                    }
                    
                    
                    BottomLineTextField(placeholder: "Meetup Title", text: $viewModel.meetupTitle)
                    
                    Menu {
                        ForEach(MeetupManager.cities, id: \.self) { city in
                            Button {
                                viewModel.setCity(city: city)
                            } label: {
                                Text(city)
                            }
                        }
                    } label: {
                        if !viewModel.city.isEmpty {
                            Text("\(viewModel.city), \(viewModel.country)")
                                .font(.headline)
                        } else {
                            Text("Select a city")
                                .font(.headline)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    
                    DatePicker("Select a date:", selection: $viewModel.meetTime, displayedComponents: [.date])
                        .padding(.top)
                        .padding(.horizontal)
                        .foregroundStyle(.gray.opacity(0.8))
                    
                    TextField("Description", text: $viewModel.meetupDescription, axis: .vertical)
                        .lineLimit(5)
                        .padding(5)
                        .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.963))
                        .padding()
                    
                    Button {
                        Task {
                            do {
                                try await viewModel.loadCurrentUser()
                                
                                if (try await viewModel.hasCreatedMeetupWithSameNameAndCity(userId: viewModel.user?.userId ?? "", meetupTitle: viewModel.meetupTitle, meetupCity: viewModel.city)) {
                                    viewModel.alertItem = AlertItem(title: Text("Error"), message: Text("You've already created a meetup in this city with that name, please don't clutter!"), dismissButton: .default(Text("OK")))
                                } else {
                                    try await viewModel.createMeetup(userId: viewModel.user?.userId ?? "")
                                    dismiss()
                                }
                                
                            } catch {
                                print("Error ocurred: \(error)")
                            }
                        }
                        
                    } label: {
                        Text("Post Meetup")
                            .padding()
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 50)
                            .background(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    Spacer()
                        .navigationTitle("Create a Meetup")
                }
                .alert(item: $viewModel.alertItem) { alertItem in
                    Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
                }
                .photosPicker(isPresented: $isImagePickerPresented, selection: $viewModel.imageSelection, matching: .images)
                .onChange(of: viewModel.imageSelection) { _, newSelection in
                    Task {
                        if let image = try await viewModel.loadImage(from: newSelection) {
                            viewModel.selectedImage = image
                        }
                    }
                }
            }
            .onAppear {
                if let city {
                    if let country {
                        let cityCountry = city + ", " + country
                        viewModel.setCity(city: cityCountry)
                    }
                }
            }
        }
    }
}


#Preview {
    MeetupCreationView()
}
