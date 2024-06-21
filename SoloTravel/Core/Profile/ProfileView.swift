import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewModel()
    @Binding var isNotAuthenticated: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .frame(width: 400)
                        .font(.system(size: 150))
                        .background(.yellow)
                        .task {
                            try? await viewModel.loadCurrentUser()
                        }
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink {
                                    SettingsView(isNotAuthenticated: $isNotAuthenticated)
                                } label: {
                                    Image(systemName: "gear")
                                        .font(.headline)
                                }
                                
                            }
                    }
                    Text("\(viewModel.user?.firstName ?? "") \(viewModel.user?.lastName ?? "")")
                        .font(.title)
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading) {
                    Text("Birthday: \(stripTime(from: viewModel.user?.birthDate ?? stripTime(from: Date())))")
                    Text("Home Country: \(viewModel.user?.homeCountry ?? "")")
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Profile")
            .background(.yellow)
            .onAppear {
                Task {
                    try await viewModel.loadCurrentUser()
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
    
}

#Preview {
    ProfileView(isNotAuthenticated: .constant(false))
}
