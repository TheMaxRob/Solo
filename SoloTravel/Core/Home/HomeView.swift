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
                    
                    Button {
                        isShowingMeetups = true
                    } label: {
                        Text("Connect")
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .background(Color.blue)
                            .foregroundColor(.white)
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
            
            if isShowingMeetups {
                MeetupsView(isShowingMeetups: $isShowingMeetups, city: viewModel.selectedCity)
                    .zIndex(1)
            }
        }
    }
}

#Preview {
    HomeView(showSignInView: .constant(false))
}
