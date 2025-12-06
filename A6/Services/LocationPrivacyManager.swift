// LocationPrivacyManager.swift
// A6 - Location Privacy System
// Precise location for owner, approximate for everyone else

import Foundation
import CoreLocation
import SwiftUI

class LocationPrivacyManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationPrivacyManager()
    
    private let locationManager = CLLocationManager()
    
    // Published properties
    @Published var preciseLocation: CLLocation?
    @Published var approximateLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled: Bool = false
    @Published var privacyRadius: Double = 5.0 // Miles
    @Published var privacyLevel: PrivacyLevel = .city
    
    // Phantom Routes - multiple decoy indicators
    @Published var phantomRoutesEnabled: Bool = false
    @Published var phantomLocations: [PhantomLocation] = []
    @Published var phantomCount: Int = 5
    
    // Privacy radius options in miles
    static let radiusOptions: [Double] = [1.0, 2.0, 5.0, 10.0, 25.0, 50.0, 100.0]
    static let phantomCountOptions: [Int] = [3, 5, 8, 12, 20]
    
    enum PrivacyLevel: String, CaseIterable {
        case precise = "Precise"
        case neighborhood = "Neighborhood"
        case city = "City"
        case region = "Region"
        case hidden = "Hidden"
        
        var radiusMiles: Double {
            switch self {
            case .precise: return 0
            case .neighborhood: return 1
            case .city: return 5
            case .region: return 25
            case .hidden: return 100
            }
        }
        
        var description: String {
            switch self {
            case .precise: return "Exact location visible"
            case .neighborhood: return "~1 mile radius"
            case .city: return "~5 mile radius"
            case .region: return "~25 mile radius"
            case .hidden: return "~100 mile radius (very approximate)"
            }
        }
        
        var icon: String {
            switch self {
            case .precise: return "location.fill"
            case .neighborhood: return "location.circle"
            case .city: return "building.2"
            case .region: return "map"
            case .hidden: return "eye.slash"
            }
        }
    }
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        loadSettings()
    }
    
    // MARK: - Settings Persistence
    
    private func loadSettings() {
        if let savedRadius = UserDefaults.standard.object(forKey: "locationPrivacyRadius") as? Double {
            privacyRadius = savedRadius
        }
        if let savedLevel = UserDefaults.standard.string(forKey: "locationPrivacyLevel"),
           let level = PrivacyLevel(rawValue: savedLevel) {
            privacyLevel = level
        }
        isLocationEnabled = UserDefaults.standard.bool(forKey: "locationEnabled")
        phantomRoutesEnabled = UserDefaults.standard.bool(forKey: "phantomRoutesEnabled")
        if let savedCount = UserDefaults.standard.object(forKey: "phantomCount") as? Int {
            phantomCount = savedCount
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(privacyRadius, forKey: "locationPrivacyRadius")
        UserDefaults.standard.set(privacyLevel.rawValue, forKey: "locationPrivacyLevel")
        UserDefaults.standard.set(isLocationEnabled, forKey: "locationEnabled")
    }
    
    // MARK: - Location Authorization
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        isLocationEnabled = true
        saveSettings()
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        isLocationEnabled = false
        saveSettings()
        locationManager.stopUpdatingLocation()
        preciseLocation = nil
        approximateLocation = nil
    }
    
    // MARK: - Privacy Controls
    
    func setPrivacyRadius(_ miles: Double) {
        privacyRadius = miles
        saveSettings()
        updateApproximateLocation()
    }
    
    func setPrivacyLevel(_ level: PrivacyLevel) {
        privacyLevel = level
        privacyRadius = level.radiusMiles
        saveSettings()
        updateApproximateLocation()
    }
    
    // MARK: - Location Processing
    
    private func updateApproximateLocation() {
        guard let precise = preciseLocation else {
            approximateLocation = nil
            return
        }
        
        if privacyLevel == .precise || privacyRadius == 0 {
            approximateLocation = precise
            return
        }
        
        // Convert miles to meters
        let radiusMeters = privacyRadius * 1609.34
        
        // Generate random offset within radius
        let randomAngle = Double.random(in: 0..<2 * .pi)
        let randomDistance = Double.random(in: 0..<radiusMeters)
        
        // Calculate offset coordinates
        let earthRadius = 6371000.0 // meters
        let lat = precise.coordinate.latitude
        let lon = precise.coordinate.longitude
        
        let latOffset = (randomDistance * cos(randomAngle)) / earthRadius * (180.0 / .pi)
        let lonOffset = (randomDistance * sin(randomAngle)) / (earthRadius * cos(lat * .pi / 180.0)) * (180.0 / .pi)
        
        let newLat = lat + latOffset
        let newLon = lon + lonOffset
        
        approximateLocation = CLLocation(latitude: newLat, longitude: newLon)
    }
    
    // MARK: - Public Access Methods
    
    /// Returns the appropriate location based on viewer's authorization
    func getLocationFor(isOwner: Bool) -> CLLocation? {
        if isOwner {
            return preciseLocation
        }
        return approximateLocation
    }
    
    /// Returns coordinate for display, with privacy applied for non-owners
    func getCoordinateFor(isOwner: Bool) -> CLLocationCoordinate2D? {
        return getLocationFor(isOwner: isOwner)?.coordinate
    }
    
    /// Returns distance from precise location to approximate (for owner info)
    func getApproximationOffset() -> Double? {
        guard let precise = preciseLocation, let approximate = approximateLocation else {
            return nil
        }
        // Return distance in miles
        return precise.distance(from: approximate) / 1609.34
    }
    
    /// Format coordinate for display
    func formatCoordinate(_ coordinate: CLLocationCoordinate2D, precision: Int = 4) -> String {
        let latDir = coordinate.latitude >= 0 ? "N" : "S"
        let lonDir = coordinate.longitude >= 0 ? "E" : "W"
        return String(format: "%.\(precision)f°%@ %.\(precision)f°%@",
                      abs(coordinate.latitude), latDir,
                      abs(coordinate.longitude), lonDir)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        preciseLocation = location
        updateApproximateLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            if isLocationEnabled {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    // MARK: - Phantom Routes System
    
    func enablePhantomRoutes(_ enabled: Bool) {
        phantomRoutesEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "phantomRoutesEnabled")
        
        if enabled {
            generatePhantomLocations()
        } else {
            phantomLocations = []
        }
    }
    
    func setPhantomCount(_ count: Int) {
        phantomCount = count
        UserDefaults.standard.set(count, forKey: "phantomCount")
        
        if phantomRoutesEnabled {
            generatePhantomLocations()
        }
    }
    
    func generatePhantomLocations() {
        guard let precise = preciseLocation else {
            phantomLocations = []
            return
        }
        
        // Phantom routes require a minimum radius to work
        // Use at least 1 mile radius even if privacy is set to Precise
        let effectiveRadius = max(privacyRadius, 1.0)
        
        var newPhantoms: [PhantomLocation] = []
        let radiusMeters = effectiveRadius * 1609.34
        let earthRadius = 6371000.0
        
        for i in 0..<phantomCount {
            // Generate phantom at random position within radius
            let angle = Double.random(in: 0..<2 * .pi)
            let distance = Double.random(in: radiusMeters * 0.3..<radiusMeters)
            
            let lat = precise.coordinate.latitude
            let lon = precise.coordinate.longitude
            
            let latOffset = (distance * cos(angle)) / earthRadius * (180.0 / .pi)
            let lonOffset = (distance * sin(angle)) / (earthRadius * cos(lat * .pi / 180.0)) * (180.0 / .pi)
            
            let phantomLat = lat + latOffset
            let phantomLon = lon + lonOffset
            
            // Generate a random heading for route direction
            let heading = Double.random(in: 0..<360)
            
            // Generate phantom route type
            let routeTypes: [PhantomLocation.RouteType] = [.walking, .driving, .transit, .cycling]
            let routeType = routeTypes[i % routeTypes.count]
            
            let phantom = PhantomLocation(
                id: UUID(),
                coordinate: CLLocationCoordinate2D(latitude: phantomLat, longitude: phantomLon),
                heading: heading,
                routeType: routeType,
                distanceFromReal: distance / 1609.34, // Convert to miles
                isActive: true
            )
            
            newPhantoms.append(phantom)
        }
        
        phantomLocations = newPhantoms
    }
    
    func refreshPhantomLocations() {
        if phantomRoutesEnabled {
            generatePhantomLocations()
        }
    }
    
    /// Get all visible indicators for non-owners (approximate + phantoms)
    func getAllVisibleIndicators(isOwner: Bool) -> [LocationIndicator] {
        var indicators: [LocationIndicator] = []
        
        if isOwner {
            // Owner sees their precise location
            if let precise = preciseLocation {
                indicators.append(LocationIndicator(
                    id: UUID(),
                    coordinate: precise.coordinate,
                    type: .precise,
                    label: "You (Precise)"
                ))
            }
            
            // Owner also sees the approximate location others see
            if let approximate = approximateLocation, privacyLevel != .precise {
                indicators.append(LocationIndicator(
                    id: UUID(),
                    coordinate: approximate.coordinate,
                    type: .approximate,
                    label: "Others See"
                ))
            }
            
            // Owner sees all phantom locations
            for phantom in phantomLocations {
                indicators.append(LocationIndicator(
                    id: phantom.id,
                    coordinate: phantom.coordinate,
                    type: .phantom,
                    label: "Phantom (\(phantom.routeType.rawValue))"
                ))
            }
        } else {
            // Non-owners see approximate + all phantoms (can't tell which is real)
            if let approximate = approximateLocation {
                indicators.append(LocationIndicator(
                    id: UUID(),
                    coordinate: approximate.coordinate,
                    type: .unknown,
                    label: "Possible Location"
                ))
            }
            
            for phantom in phantomLocations {
                indicators.append(LocationIndicator(
                    id: phantom.id,
                    coordinate: phantom.coordinate,
                    type: .unknown,
                    label: "Possible Location"
                ))
            }
        }
        
        return indicators
    }
}

// MARK: - Phantom Location Model

struct PhantomLocation: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let heading: Double
    let routeType: RouteType
    let distanceFromReal: Double // in miles
    let isActive: Bool
    
    enum RouteType: String {
        case walking = "Walking"
        case driving = "Driving"
        case transit = "Transit"
        case cycling = "Cycling"
    }
}

// MARK: - Location Indicator for Display

struct LocationIndicator: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let type: IndicatorType
    let label: String
    
    enum IndicatorType {
        case precise    // Real location (owner only)
        case approximate // Approximate real location
        case phantom    // Decoy location
        case unknown    // For non-owners, all look the same
        
        var color: Color {
            switch self {
            case .precise: return Color(hex: "22c55e")
            case .approximate: return Color(hex: "f59e0b")
            case .phantom: return Color(hex: "8b5cf6")
            case .unknown: return Color(hex: "6b7280")
            }
        }
        
        var icon: String {
            switch self {
            case .precise: return "location.fill"
            case .approximate: return "location.circle"
            case .phantom: return "location.slash"
            case .unknown: return "mappin.circle.fill"
            }
        }
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
