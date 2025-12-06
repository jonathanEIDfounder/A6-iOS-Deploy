// LocationPrivacyView.swift
// A6 - Location Privacy Control Panel
// Precise for owner, approximate for everyone else

import SwiftUI
import CoreLocation
import MapKit

struct LocationPrivacyView: View {
    @EnvironmentObject var runtime: SovereignRuntime
    @StateObject private var locationManager = LocationPrivacyManager.shared
    @State private var showingRadiusSlider = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        locationStatusCard
                        privacyLevelSelector
                        customRadiusSection
                        phantomRoutesSection
                        mapPreviewSection
                        indicatorLegend
                    }
                    .padding()
                }
            }
            .navigationTitle("Location Privacy")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            updateMapRegion()
        }
    }
    
    // MARK: - Location Status Card
    
    private var locationStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: locationManager.isLocationEnabled ? "location.fill" : "location.slash")
                    .font(.title2)
                    .foregroundColor(locationManager.isLocationEnabled ? Color(hex: "22c55e") : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Location Services")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(locationStatusText)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { locationManager.isLocationEnabled },
                    set: { enabled in
                        if enabled {
                            locationManager.startUpdatingLocation()
                        } else {
                            locationManager.stopUpdatingLocation()
                        }
                    }
                ))
                .tint(Color(hex: "1DE0C2"))
            }
            
            if let precise = locationManager.preciseLocation {
                Divider().background(Color.gray.opacity(0.3))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Precise Location")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(locationManager.formatCoordinate(precise.coordinate))
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(Color(hex: "22c55e"))
                    }
                    
                    Spacer()
                    
                    if runtime.isOwner {
                        Image(systemName: "eye.fill")
                            .foregroundColor(Color(hex: "1DE0C2"))
                        Text("Only You")
                            .font(.caption)
                            .foregroundColor(Color(hex: "1DE0C2"))
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1DE0C2").opacity(0.2), lineWidth: 1)
        )
    }
    
    private var locationStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Tap to enable location"
        case .denied, .restricted:
            return "Location access denied"
        case .authorizedWhenInUse, .authorizedAlways:
            return locationManager.isLocationEnabled ? "Active" : "Disabled"
        @unknown default:
            return "Unknown"
        }
    }
    
    // MARK: - Privacy Level Selector
    
    private var privacyLevelSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundColor(Color(hex: "1DE0C2"))
                Text("Privacy Level")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                ForEach(LocationPrivacyManager.PrivacyLevel.allCases, id: \.self) { level in
                    privacyLevelRow(level)
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1DE0C2").opacity(0.2), lineWidth: 1)
        )
    }
    
    private func privacyLevelRow(_ level: LocationPrivacyManager.PrivacyLevel) -> some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            locationManager.setPrivacyLevel(level)
            updateMapRegion()
        }) {
            HStack {
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundColor(locationManager.privacyLevel == level ? Color(hex: "1DE0C2") : .gray)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if locationManager.privacyLevel == level {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "1DE0C2"))
                }
            }
            .padding()
            .background(locationManager.privacyLevel == level ? Color(hex: "1DE0C2").opacity(0.1) : Color(hex: "0d0d14"))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Custom Radius Section
    
    private var customRadiusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .foregroundColor(Color(hex: "1DE0C2"))
                Text("Custom Radius")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(String(format: "%.1f", locationManager.privacyRadius)) mi")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(Color(hex: "1DE0C2"))
            }
            
            VStack(spacing: 12) {
                Slider(
                    value: Binding(
                        get: { locationManager.privacyRadius },
                        set: { newValue in
                            locationManager.setPrivacyRadius(newValue)
                            updateMapRegion()
                        }
                    ),
                    in: 0.5...100,
                    step: 0.5
                )
                .tint(Color(hex: "1DE0C2"))
                
                HStack {
                    Text("0.5 mi")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("100 mi")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Quick select buttons
            HStack(spacing: 8) {
                ForEach(LocationPrivacyManager.radiusOptions, id: \.self) { radius in
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        locationManager.setPrivacyRadius(radius)
                        updateMapRegion()
                    }) {
                        Text("\(Int(radius))")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(locationManager.privacyRadius == radius ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(locationManager.privacyRadius == radius ? Color(hex: "1DE0C2") : Color(hex: "0d0d14"))
                            .cornerRadius(16)
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1DE0C2").opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Phantom Routes Section
    
    private var phantomRoutesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .foregroundColor(Color(hex: "8b5cf6"))
                Text("Phantom Routes")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { locationManager.phantomRoutesEnabled },
                    set: { enabled in
                        locationManager.enablePhantomRoutes(enabled)
                    }
                ))
                .tint(Color(hex: "8b5cf6"))
            }
            
            Text("Display multiple decoy location indicators. Others cannot distinguish your real location from phantoms.")
                .font(.caption)
                .foregroundColor(.gray)
            
            if locationManager.phantomRoutesEnabled {
                Divider().background(Color.gray.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Number of Phantoms")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        ForEach(LocationPrivacyManager.phantomCountOptions, id: \.self) { count in
                            Button(action: {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                locationManager.setPhantomCount(count)
                            }) {
                                Text("\(count)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(locationManager.phantomCount == count ? .black : .white)
                                    .frame(width: 44, height: 36)
                                    .background(locationManager.phantomCount == count ? Color(hex: "8b5cf6") : Color(hex: "0d0d14"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        locationManager.refreshPhantomLocations()
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Regenerate Phantoms")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(hex: "8b5cf6").opacity(0.2))
                        .foregroundColor(Color(hex: "8b5cf6"))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "8b5cf6").opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Map Preview Section
    
    private var mapPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "map")
                    .foregroundColor(Color(hex: "1DE0C2"))
                Text("Privacy Preview")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Owner View")
                    .font(.caption)
                    .foregroundColor(Color(hex: "1DE0C2"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "1DE0C2").opacity(0.15))
                    .cornerRadius(8)
            }
            
            Map(coordinateRegion: $mapRegion, annotationItems: locationManager.getAllVisibleIndicators(isOwner: runtime.isOwner)) { indicator in
                MapAnnotation(coordinate: indicator.coordinate) {
                    VStack(spacing: 2) {
                        Image(systemName: indicator.type.icon)
                            .font(.title3)
                            .foregroundColor(indicator.type.color)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                        
                        if runtime.isOwner {
                            Text(indicator.label)
                                .font(.system(size: 9))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .frame(height: 250)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "1DE0C2").opacity(0.3), lineWidth: 1)
            )
            
            if let offset = locationManager.getApproximationOffset() {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                    Text("Others see a location ~\(String(format: "%.1f", offset)) miles from your actual position")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1DE0C2").opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Indicator Legend
    
    private var indicatorLegend: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Indicator Legend")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                legendItem(icon: "location.fill", color: Color(hex: "22c55e"), label: "Precise")
                legendItem(icon: "location.circle", color: Color(hex: "f59e0b"), label: "Approximate")
                legendItem(icon: "location.slash", color: Color(hex: "8b5cf6"), label: "Phantom")
            }
        }
        .padding()
        .background(Color(hex: "1a1a2e"))
        .cornerRadius(12)
    }
    
    private func legendItem(icon: String, color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateMapRegion() {
        if let location = locationManager.preciseLocation {
            let spanDelta = max(0.01, locationManager.privacyRadius / 30)
            mapRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
            )
        }
    }
}

#Preview {
    LocationPrivacyView()
        .environmentObject(SovereignRuntime.shared)
}
