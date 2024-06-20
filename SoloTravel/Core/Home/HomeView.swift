import SwiftUI

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    @Binding var showSignInView: Bool
    @State var isShowingMeetups: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 10) {
                    Text("S o l o")
                        .bold()
                        .font(Font.system(size: 60))
                    Text("Connect with other travelers")
                        .bold()
                    
                    Spacer()
                        .frame(height: 175)
                    
                    Text("Where are you staying?").bold()
                    HStack {
                        TextField("City", text: $viewModel.selectedCity)
                        TextField("Hotel/Hostel", text:$viewModel.selectedStay)
                    }
                    .padding(.bottom)
                    .textFieldStyle(.roundedBorder)
                    .shadow(radius: 3)
                    
                    NavigationLink {
                        MeetupsView(isShowingMeetups: $isShowingMeetups, city: viewModel.selectedCity)
                            .zIndex(1)
                    } label: {
                        Text("Connect")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .background(.yellow)
            }
        }
    }
}

#Preview {
    HomeView(showSignInView: .constant(false))
}
