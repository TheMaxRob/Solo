//
//  MeetupCreationView.swift
//  SoloTravel
//
//  Created by Max Roberts on 6/4/24.
//

import SwiftUI
import MapboxMaps

struct MeetupCreationView: View {
    @StateObject private var viewModel = MeetupCreationViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isImagePickerPresented = false
    @EnvironmentObject private var userStateManager: UserStateManager
    var location: CLLocationCoordinate2D
    @State private var selectedTags: Set<Tag> = []
    
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
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.gray)
                        Text("Location: \(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical, 20)
                    
                    DatePicker("Select a date:", selection: $viewModel.meetTime, displayedComponents: [.date])
                        .padding(.top)
                        .padding(.horizontal)
                        .foregroundStyle(.gray.opacity(0.8))
                    
                    
                    // Tags Section
                    Text("Select Tags for Your Meetup")
                        .font(.headline)
                        .padding(.bottom, 10) // Add space below the title

                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(Tag.allCases, id: \.self) { tag in
                                tagView(for: tag)
                            }
                        }
                        .padding()
                    }
                    .frame(height: 200) 

                    
                    .frame(height: 200)
                    
                    TextField("Description", text: $viewModel.meetupDescription, axis: .vertical)
                        .lineLimit(5)
                        .padding(5)
                        .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.963))
                        .padding()
                    
                    Button {
                        Task {
                            do {
                                // Modify the duplicate check to use location instead of city
                                if (try await viewModel.hasCreatedMeetupNearLocation(
                                    userId: userStateManager.currentUser?.userId ?? "",
                                    meetupTitle: viewModel.meetupTitle,
                                    location: location
                                )) {
                                    viewModel.alertItem = AlertItem(
                                        title: Text("Error"),
                                        message: Text("You've already created a meetup near this location. Please choose a different location!"),
                                        dismissButton: .default(Text("OK"))
                                    )
                                } else {
                                    try await viewModel.createMeetup(
                                        userId: userStateManager.currentUser?.userId ?? "",
                                        location: location,
                                        selectedTags: selectedTags
                                    )
                                    dismiss()
                                }
                            } catch {
                                print("Error occurred: \(error)")
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
        }
    }
    func tagView(for tag: Tag) -> some View {
        Text(tag.rawValue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(selectedTags.contains(tag) ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .foregroundColor(selectedTags.contains(tag) ? .green : .gray)
            .font(.footnote)
            .clipShape(Capsule())
            .onTapGesture {
                if selectedTags.contains(tag) {
                    selectedTags.remove(tag)
                } else {
                    selectedTags.insert(tag)
                }
            }
    }

}

#Preview {
    MeetupCreationView(location: CLLocationCoordinate2D())
}

//
//struct MultipleSelectionRow: View {
//    let label: String
//    let isSelected: Bool
//    let onTap: () -> Void
//    
//    var body: some View {
//        Button(action: onTap) {
//            HStack {
//                Text(label)
//                Spacer()
//                if isSelected {
//                    Image(systemName: "checkmark")
//                }
//            }
//        }
//    }
//}
