//
//  MapView.swift
//  SoloTravel
//
//  Created by Max Roberts on 1/11/25.
//

import SwiftUI
import MapboxMaps

@MainActor
final class MapViewModel: ObservableObject {
    @Published var meetups: [Meetup] = []
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @Published var meetupPoints: [CLLocationCoordinate2D] = []
    
    func fetchMeetups(userStateManager: UserStateManager) async throws {
        meetups = try await userStateManager.fetchMeetups(start: startDate, end: endDate)
        //print("meetups assigned in MapViewModel: \(meetups)")
    }
}

struct MapView: View {
    @State private var selectedMeetup: Meetup? = nil
    @State private var showingCreationView = false
    @State private var tappedLocation: CLLocationCoordinate2D? = nil
    @State private var showingDatePicker = false
    @StateObject private var viewModel = MapViewModel()
    @EnvironmentObject private var userStateManager: UserStateManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(initialViewport: .camera(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 2, bearing: 0, pitch: 0)) {
                    ForEvery(viewModel.meetups) { meetup in
                        CircleAnnotation(centerCoordinate: meetup.location)
                            .circleRadius(5)
                            .circleColor(StyleColor(.systemBlue))
                            .onTapGesture {
                                selectedMeetup = meetup
                            }
                        PointAnnotation(coordinate: meetup.location)
                    }
                }
                    .onMapTapGesture { context in
                        tappedLocation = context.coordinate
                        showingCreationView = true
                    }
                    .ignoresSafeArea()
                
                // Date Range Button Overlay
                VStack {
                    Button {
                        showingDatePicker.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text("\(viewModel.startDate.formatted(date: .abbreviated, time: .omitted)) - \(viewModel.endDate.formatted(date: .abbreviated, time: .omitted))")
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .padding()
                    
                    Spacer()
                }
                
                // Date Picker Popup
                if showingDatePicker {
                    VStack {
                        HStack {
                            Text("Select Date Range")
                                .font(.headline)
                            Spacer()
                            Button {
                                showingDatePicker = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding()
                        
                        DatePicker("Start Date",
                                  selection: $viewModel.startDate,
                                  displayedComponents: [.date])
                            .padding(.horizontal)
                        
                        DatePicker("End Date",
                                  selection: $viewModel.endDate,
                                  in: viewModel.startDate...,
                                  displayedComponents: [.date])
                            .padding(.horizontal)
                        
                        Button("Apply") {
                            Task {
                                do {
                                    try await viewModel.fetchMeetups(userStateManager: userStateManager)
                                } catch {
                                    print("Failed to fetch meetups: \(error)")
                                }
                            }
                            showingDatePicker = false
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .frame(width: 300)
                    .shadow(radius: 10)
                    .transition(.scale)
                }

            }
        }
        .navigationDestination(item: $selectedMeetup) { meetup in
            MeetupDetailsView(meetup: meetup)
        }
        .navigationDestination(isPresented: $showingCreationView) {
            if let location = tappedLocation {
                MeetupCreationView(location: location)
            }
        }
        .task {
            do {
                try await viewModel.fetchMeetups(userStateManager: userStateManager)
            } catch {
                print("Failed to fetch meetups: \(error)")
            }
        }
        //.ignoresSafeArea()
        .animation(.spring(), value: showingDatePicker)
    }
}
