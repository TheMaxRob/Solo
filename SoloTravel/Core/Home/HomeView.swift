import SwiftUI

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    @Binding var isNotAuthenticated: Bool
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
                        BottomLineTextField(placeholder: "City", text: $viewModel.selectedCity)
                        BottomLineTextField(placeholder: "Timeframe", text: $viewModel.selectedStay)
                    }
                    .padding(.bottom)
                    
                    NavigationLink {
                        MeetupsView(isShowingMeetups: $isShowingMeetups, city: viewModel.selectedCity)
                            .zIndex(1)
                    } label: {
                        Text("Connect")
                            .padding()
                            .background(viewModel.selectedCity.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .disabled(viewModel.selectedCity.isEmpty)
                    Spacer()
                }
                
                .padding(.horizontal)
                .background(.yellow)
            }
        }
    }
}

#Preview {
    HomeView(isNotAuthenticated: .constant(false))
}
