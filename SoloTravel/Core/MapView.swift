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
    @Published var desiredTags: Set<Tag> = []
    
    func fetchMeetups(userStateManager: UserStateManager) async throws {
        let allMeetups = try await userStateManager.fetchMeetups(start: startDate, end: endDate)
        print("meetups assigned in MapViewModel: \(meetups)")
        if desiredTags.isEmpty {
            self.meetups = allMeetups
        } else {
            print("filtering based on tags...")
            self.meetups = allMeetups.filter { meetup in
                guard let meetupTags = meetup.tags else { return false }
                return !Set(meetupTags).isDisjoint(with: desiredTags)
            }
            print("meetups displayed: \(meetups)")
        }
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
    @State private var showingTagFilter = false
    
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515),
            span: MKCoordinateSpan(latitudeDelta: 150, longitudeDelta: 150)
        )
    
    var body: some View {
        NavigationStack {
            ZStack {

                ClusterMapViewRepresentable(
                    meetups: viewModel.meetups,
                    searchResults: searchResults,
                    region: $region,
                    selectedMeetup: $selectedMeetup,
                    tappedLocation: $tappedLocation,
                    onClusterTap: { cluster in
                        zoomInOnCluster(cluster)
                    }
                )
                .ignoresSafeArea()
                .sheet(isPresented: $isSheetPresented) {
                    SheetView(
                        searchResults: $searchResults,
                        isSheetPresented: $isSheetPresented,
                        zoomToLocation: { location in
                            region = MKCoordinateRegion(
                                center: location,
                                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                            )
                        }
                    )
                        .onChange(of: searchResults) { _, results in
                            if let firstResult = results.first {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    region = MKCoordinateRegion(
                                        center: firstResult.location,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    )
                                }
                            }
                        }
                }
                
                // Date Range Button Overlay
                VStack {
                    HStack {
                        
                        // Calendar button
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
                        
                        // Search Button
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
                    
                    HStack {
                        
                        Spacer()
                        // Filter Button
                        Button {
                            showingTagFilter.toggle()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 20))
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 10)
                    }
                    
                    
                    Spacer()
                }
                
                // Tag Filter Popup
                if showingTagFilter {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Filter by Tags")
                                .font(.headline)
                            Spacer()
                            Button {
                                showingTagFilter = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        Divider().padding(.horizontal, 8)
                        
                        // List (or grid) of tags
                        ScrollView {
                            LazyVStack(alignment: .leading) {
                                ForEach(Tag.allCases, id: \.self) { tag in
                                    // A toggle or a row that toggles membership in desiredTags
                                    Button {
                                        if viewModel.desiredTags.contains(tag) {
                                            viewModel.desiredTags.remove(tag)
                                        } else {
                                            viewModel.desiredTags.insert(tag)
                                        }
                                    } label: {
                                        HStack {
                                            // Show a checkmark if selected
                                            Image(systemName: viewModel.desiredTags.contains(tag)
                                                  ? "checkmark.square"
                                                  : "square")
                                            Text(tag.rawValue)
                                            Spacer()
                                        }
                                        .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                }
                            }
                        }
                        .frame(maxHeight: 250)
                        
                        Divider().padding(.horizontal, 8)
                        
                        // Apply button
                        Button("Apply") {
                            Task {
                                do {
                                    try await viewModel.fetchMeetups(userStateManager: userStateManager)
                                } catch {
                                    print("Failed to fetch meetups: \(error)")
                                }
                            }
                            showingTagFilter = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()

                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                    .padding()
                    .transition(.scale)
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
        // Data fetch
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
