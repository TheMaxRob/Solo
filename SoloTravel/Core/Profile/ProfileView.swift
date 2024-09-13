import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published var profileImage: UIImage? = nil
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        } catch {
            print("Error loading current user: \(error)")
            throw error
        }
    }
    
    
    func loadImage(from url: String) async throws {
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
}

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewModel()
    @Binding var isNotAuthenticated: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 85))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                    }
                    
                    Text("\(viewModel.user?.firstName ?? "") \(viewModel.user?.lastName ?? "")")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                VStack {
                    // My Meetups
                    NavigationLink {
                        MyMeetupsView(user: viewModel.user ?? DBUser(userId: ""))
                    } label: {
                        ProfileListItem(
                            text: "My Meetups",
                            isHighlighted: viewModel.user?.hasNewRequest == true
                        )
                    }
                    .font(viewModel.user?.hasNewRequest == true ? .system(size: 18, weight: .bold) : .system(size: 16))

                    // Upcoming Meetups
                    NavigationLink {
                        UpcomingMeetupsView(user: viewModel.user ?? DBUser(userId: ""))
                    } label: {
                        ProfileListItem(
                            text: "Upcoming Meetups",
                            isHighlighted: viewModel.user?.hasNewAcceptance == true
                        )
                    }
                    .font(viewModel.user?.hasNewAcceptance == true ? .system(size: 18, weight: .bold) : .system(size: 16))

                    NavigationLink {
                        BookmarkedMeetupsView(user: viewModel.user ?? DBUser(userId: ""))
                    } label: {
                        ProfileListItem(text: "Bookmarked Meetups", isHighlighted: false)
                    }
                    NavigationLink {
                        PublicProfileView(userId: viewModel.user?.userId ?? "")
                    } label: {
                        ProfileListItem(text: "My Public Profile", isHighlighted: false)
                    }
                    Divider()
                        .padding(8)
                    
                    NavigationLink {
                        if viewModel.user != nil {
                            EditUserProfileView(user: viewModel.user!)
                        }
                        
                    } label: {
                        Label("Edit Profile", systemImage: "square.and.pencil")
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal)
                
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView(isNotAuthenticated: $isNotAuthenticated)) {
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .frame(width: 400)
            .navigationTitle("Profile")
            .onAppear {
                Task {
                    do {
                        try await viewModel.loadCurrentUser()
                        print("User loaded: \(viewModel.user) ")
                        if let photoURL = viewModel.user?.photoURL, !photoURL.isEmpty {
                            try await viewModel.loadImage(from: photoURL)
                            print("Profile image loaded")
                        } else {
                            print("No photo URL available for user")
                        }
                    } catch {
                        print("Error in onAppear: \(error)")
                    }
                }
            }
            
        }
    }
}

    private func stripTime(from originalDate: Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let date = dateFormatter.date(from: originalDate.description) ?? Date()
        print(date)
        return date
    }


#Preview {
    ProfileView(isNotAuthenticated: .constant(false))
}


struct ProfileListItem: View {
    var text: String
    var isHighlighted: Bool

    var body: some View {
        ZStack {
            VStack {
                Divider()
                    .padding(8)
                Text(text)
                    .foregroundStyle(.black)
                    .fontWeight(isHighlighted ? .bold : .regular)
                    
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ProfileListItem(text: "Example Text", isHighlighted: false)
        .previewLayout(.sizeThatFits)
        .padding()
}

