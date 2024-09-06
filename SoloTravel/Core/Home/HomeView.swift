import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @Binding var isNotAuthenticated: Bool
    @State private var selectedCountry: String?
    @State private var isShowingTimeFrameModal = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 10) {
                    Text("S o l o")
                        .bold()
                        .font(Font.system(size: 60))
                    Text("Connect with other travelers")
                        .bold()
                    
                    Spacer().frame(height: 100)
                    LazyVGrid(columns: viewModel.columns, spacing: 20, content: {
                        ForEach(viewModel.countries, id: \.self) { country in
                            CountryCardView(country: country)
                                .onTapGesture {
                                    selectedCountry = country
                                    isShowingTimeFrameModal = true
                                }
                        }
                    })
                    Spacer()
                }
                .padding(.horizontal)
                //.background(Color.yellow)
            }
            
            if isShowingTimeFrameModal, let country = selectedCountry {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isShowingTimeFrameModal = false
                        }
                    
                    VStack {
                        TimeFrameModalView(isShowingModal: $isShowingTimeFrameModal, country: country)
                            .frame(width: 350, height: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 10)
                            .overlay(
                                Button(action: {
                                    isShowingTimeFrameModal = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding()
                                },
                                alignment: .topTrailing
                            )
                    }
                    
                }
                .transition(.opacity)
                .animation(.easeInOut, value: isShowingTimeFrameModal)
            }
        }
    }
}

#Preview {
    HomeView(isNotAuthenticated: .constant(false))
}
