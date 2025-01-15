//
//  MapView.swift
//  SoloTravel
//
//  Created by Max Roberts on 1/11/25.
//

import SwiftUI
import MapKit

@MainActor
final class MapViewModel: ObservableObject {
    @Published var meetups: [Meetup] = []
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @Published var meetupPoints: [CLLocationCoordinate2D] = []
    
    func fetchMeetups(userStateManager: UserStateManager) async throws {
        meetups = try await userStateManager.fetchMeetups(start: startDate, end: endDate)
        print("meetups assigned in MapViewModel: \(meetups)")
    }
}

struct MapView: View {
    @State private var selectedMeetup: Meetup? = nil
    @State private var showingCreationView = false
    @State private var tappedLocation: CLLocationCoordinate2D? = nil
    @State private var selectedLocation: SearchResult?
    @State private var showingDatePicker = false
    @StateObject private var viewModel = MapViewModel()
    @EnvironmentObject private var userStateManager: UserStateManager
    @State private var position = MapCameraPosition.automatic
    @State private var searchResults = [SearchResult]()
    @State private var isSheetPresented: Bool = true
    @State private var scene: MKLookAroundScene?
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapReader { proxy in
                    Map(position: $position, selection: $selectedLocation) {
                        ForEach(searchResults) { result in
                            Marker(coordinate: result.location) {
                                Image(systemName: "mappin")
                                    .onTapGesture {
                                        position = .region(MKCoordinateRegion(
                                                        center: result.location,
                                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                                    ))
                                    }
                            }
                            .tag(result)
                        }
                        ForEach(viewModel.meetups) { meetup in
                            Annotation(meetup.title, coordinate: meetup.location) {
                                Image(systemName: "mappin")
                                    .font(.largeTitle)
                                    .onTapGesture {
                                        selectedMeetup = meetup
                                    }

                            }
                                
                            //PointAnnotation(coordinate: meetup.location)
                        }
                    }
                    .onTapGesture { position in
                        tappedLocation = proxy.convert(position, from: .local)
                        showingCreationView = true
                    }
                    .onChange(of: selectedLocation) {
                        if let selectedLocation {
                            Task {
                                scene = try? await fetchScene(for: selectedLocation.location)
                            }
                        }
                        isSheetPresented = selectedLocation == nil
                    }
                    .onChange(of: searchResults) {
                        if let firstResult = searchResults.first, searchResults.count == 1 {
                            selectedLocation = firstResult
                        }
                    }
                    .sheet(isPresented: $isSheetPresented, content: {
                        SheetView(searchResults: $searchResults)
                    })
                    .ignoresSafeArea()
                }
                // Date Range Button Overlay
                VStack {
                    
                    HStack {
                        
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
                        
                        
                        Button {
                            isSheetPresented = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
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
    
    private func fetchScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        let lookAroundScene = MKLookAroundSceneRequest(coordinate: coordinate)
        return try await lookAroundScene.scene
    }
}
