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
                    NavigationLink {
                        MyMeetupsView(user: viewModel.user ?? DBUser(userId: ""))
                    } label: {
                        ProfileListItem(text: "My Meetups")
                    }
                    NavigationLink {
                        UpcomingMeetupsView(user: viewModel.user ?? DBUser(userId: ""))
                    } label: {
                        ProfileListItem(text: "Upcoming Meetups")
                    }
                    NavigationLink {
                        BookmarkedMeetupsView(user: viewModel.user ?? DBUser(userId: ""))
                    } label: {
                        ProfileListItem(text: "Boomarked Meetups")
                    }               
                    NavigationLink {
                        PublicProfileView(userId: viewModel.user?.userId ?? "")
                    } label: {
                        ProfileListItem(text: "My Public Profile")
                    }
                    Divider()
                        .padding(8)
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
            .background(.yellow)
            .navigationTitle("Profile")
            .onAppear {
                Task {
                    do {
                        try await viewModel.loadCurrentUser()
                        print("User loaded")
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

    var body: some View {
        ZStack {
            VStack {
                Divider()
                    .padding(8)
                Text(text)
                    .foregroundStyle(.black)
                    
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ProfileListItem(text: "Example Text")
        .previewLayout(.sizeThatFits)
        .padding()
}

