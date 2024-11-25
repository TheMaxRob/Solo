import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published var profileImage: UIImage? = nil
    @Published var errorMessage: String? = nil
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.fetchUser(userId: authDataResult.uid)
        } catch {
            errorMessage = "Error loading your account."
        }
    }
    
    
    func loadImage(from url: String) async throws {
        print("photoURL for loading: \(url)")
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
}

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State private var isErrorAlertPresented = false
    @Binding var isNotAuthenticated: Bool
    var user: DBUser

    var body: some View {
        NavigationView {
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
                    
                    Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                VStack {
                    // My Meetups
                    NavigationLink {
                        MyMeetupsView(user: user)
                    } label: {
                        ProfileListItem(
                            text: "My Meetups",
                            isHighlighted: user.hasNewRequest == true,
                            user: user
                        )
                    }
                    .font(user.hasNewRequest == true ? .system(size: 18, weight: .bold) : .system(size: 16))

                    // Upcoming Meetups
                    NavigationLink {
                        UpcomingMeetupsView(user: user)
                    } label: {
                        ProfileListItem(
                            text: "Upcoming Meetups",
                            isHighlighted: user.hasNewAcceptance == true,
                            user: user
                        )
                    }
                    .font(user.hasNewAcceptance == true ? .system(size: 18, weight: .bold) : .system(size: 16))

                    NavigationLink {
                        BookmarkedMeetupsView(user: user)
                    } label: {
                        ProfileListItem(text: "Bookmarked Meetups", isHighlighted: false, user: user)
                    }
                    NavigationLink {
                        PublicProfileView(profileUser: user, user: user)
                    } label: {
                        ProfileListItem(text: "My Public Profile", isHighlighted: false, user: user)
                    }
                    Divider()
                        .padding(8)
                    
                    NavigationLink {
                        EditUserProfileView()
                    } label: {
                        Label("Edit Profile", systemImage: "square.and.pencil")
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(isNotAuthenticated: $isNotAuthenticated)) {
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            //.frame(width: 400)
            .onAppear {
                Task {
                    do {
                        //try await viewModel.loadCurrentUser()
                        if let photoURL = user.photoURL, !photoURL.isEmpty {
                            try await viewModel.loadImage(from: photoURL)
                            print("Profile image loaded")
                        } else {
                            print("No photo URL available for user")
                        }
                    } catch {
                        isErrorAlertPresented = true
                    }
                }
            }
            .alert(isPresented: $isErrorAlertPresented) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Something went wrong."), dismissButton: .default(Text("OK")))
            }
            .offset(y: -50)
            Spacer()
            
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
    ProfileView(isNotAuthenticated: .constant(false), user: DBUser(userId: ""))
}


struct ProfileListItem: View {
    @Environment(\.colorScheme) var colorScheme
    var text: String
    var isHighlighted: Bool
    var user: DBUser

    var body: some View {
        ZStack {
            VStack {
                Divider()
                    .padding(8)
                Text(text)
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .fontWeight(isHighlighted ? .bold : .regular)
                    
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ProfileListItem(text: "Example Text", isHighlighted: false, user: DBUser(userId: ""))
        .previewLayout(.sizeThatFits)
        .padding()
}

