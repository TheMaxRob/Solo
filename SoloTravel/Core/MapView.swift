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
    
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515),
            span: MKCoordinateSpan(latitudeDelta: 150, longitudeDelta: 150)
        )
    
    var body: some View {
        NavigationStack {
            ZStack {

                ClusterMapViewRepresentable(
                    meetups: viewModel.meetups,
                    region: $region,
                    selectedMeetup: $selectedMeetup,
                    tappedLocation: $tappedLocation,
                    onClusterTap: { cluster in
                        zoomInOnCluster(cluster)
                    }
                )
                .ignoresSafeArea()
                
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
            .onChange(of: tappedLocation) { _, newValue in
                // If there's a new tapped location, show the creation view
                if newValue != nil {
                    showingCreationView = true
                }
            }
            // 6) Data fetch
            .task {
                do {
                    try await viewModel.fetchMeetups(userStateManager: userStateManager)
                    print("AFTER fetchMeetups: \(viewModel.meetups)")
                } catch {
                    print("Failed to fetch meetups: \(error)")
                }
            }
        }
    
    
    /// Example: zoom in on the cluster's bounding region
    private func zoomInOnCluster(_ cluster: MKClusterAnnotation) {
        let annotations = cluster.memberAnnotations
        guard !annotations.isEmpty else { return }
        
        // Create a MKMapRect that includes all member annotations
        let mapRects = annotations.map { MKMapRect(origin: MKMapPoint($0.coordinate), size: MKMapSize(width: 0, height: 0)) }
        let fittingRect = mapRects.reduce(MKMapRect.null) { $0.union($1) }
        
        // Convert to region (with some padding)
        var regionThatFits = MKCoordinateRegion(fittingRect)
        // Optional: adjust span or add a little extra delta
        regionThatFits.span.latitudeDelta *= 2
        regionThatFits.span.longitudeDelta *= 2
        
        region = regionThatFits
    }
}
