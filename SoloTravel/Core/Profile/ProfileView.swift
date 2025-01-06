import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published var profileImage: UIImage? = nil
    @Published var errorMessage: String? = nil
        
    func loadImage(from url: String) async throws {
        print("photoURL for loading: \(url)")
        profileImage = try await UserManager.shared.loadImage(from: url)
    }
}

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State private var isErrorAlertPresented = false
    @Binding var isNotAuthenticated: Bool
    @EnvironmentObject private var userStateManager: UserStateManager

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    if let profileImage = userStateManager.profileImage {
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
                    Text("\(userStateManager.currentUser?.firstName ?? "") \(userStateManager.currentUser?.lastName ?? "")")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                VStack {
                    // My Meetups
                    NavigationLink {
                        MyMeetupsView()
                    } label: {
                        ProfileListItem(
                            text: "My Meetups",
                            isHighlighted: userStateManager.currentUser?.hasNewRequest == true
                        )
                    }
                    .font(userStateManager.currentUser?.hasNewRequest == true ? .system(size: 18, weight: .bold) : .system(size: 16))

                    // Upcoming Meetups
                    NavigationLink {
                        UpcomingMeetupsView()
                    } label: {
                        ProfileListItem(
                            text: "Upcoming Meetups",
                            isHighlighted: userStateManager.currentUser?.hasNewAcceptance == true
                        )
                    }
                    .font(userStateManager.currentUser?.hasNewAcceptance == true ? .system(size: 18, weight: .bold) : .system(size: 16))

                    NavigationLink {
                        BookmarkedMeetupsView()
                    } label: {
                        ProfileListItem(text: "Bookmarked Meetups", isHighlighted: false)
                    }
                    NavigationLink {
                        PublicProfileView(profileUser: userStateManager.currentUser)
                    } label: {
                        ProfileListItem(text: "My Public Profile", isHighlighted: false)
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
                    if let photoURL = userStateManager.currentUser?.photoURL, !photoURL.isEmpty {
                        print("Profile image loaded")
                    } else {
                        print("No photo URL available for user")
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
    ProfileView(isNotAuthenticated: .constant(false))
}


struct ProfileListItem: View {
    @Environment(\.colorScheme) var colorScheme
    var text: String
    var isHighlighted: Bool

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
    ProfileListItem(text: "Example Text", isHighlighted: false)
        .previewLayout(.sizeThatFits)
        .padding()
}

