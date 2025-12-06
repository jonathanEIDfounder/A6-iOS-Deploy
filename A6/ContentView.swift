// ContentView.swift
// A6 - The Sovereign Singularity System
// iPhone XR Native UI
// GHOST PROTOCOL: UI Integration

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var runtime: SovereignRuntime
    @State private var selectedTab: Tab = .generate
    
    enum Tab {
        case generate, history, transpiler, ghost, location, textile, cortex, settings
    }
    
    var body: some View {
        MainTabView(selectedTab: $selectedTab, isOwner: runtime.isOwner)
            .preferredColorScheme(.dark)
            .privacyShield()
            .embedAuthorship()
    }
}

struct MainTabView: View {
    @Binding var selectedTab: ContentView.Tab
    let isOwner: Bool
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GenerateView()
                .tabItem {
                    Image(systemName: "wand.and.stars")
                    Text("Generate")
                }
                .tag(ContentView.Tab.generate)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .tag(ContentView.Tab.history)
            
            TranspilerView()
                .tabItem {
                    Image(systemName: "atom")
                    Text("Q++RS")
                }
                .tag(ContentView.Tab.transpiler)
            
            GhostProtocolView()
                .tabItem {
                    Image(systemName: "eye.slash.circle")
                    Text("Ghost")
                }
                .tag(ContentView.Tab.ghost)
            
            LocationPrivacyView()
                .tabItem {
                    Image(systemName: "location.viewfinder")
                    Text("Location")
                }
                .tag(ContentView.Tab.location)
            
            HolographicTextileView()
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text("Textile")
                }
                .tag(ContentView.Tab.textile)
            
            CortexView()
                .tabItem {
                    Image(systemName: "brain")
                    Text("Cortex")
                }
                .tag(ContentView.Tab.cortex)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(ContentView.Tab.settings)
        }
        .tint(Color(hex: "1DE0C2"))
    }
}

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
            (a, r, g, b) = (1, 1, 1, 0)
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

#Preview {
    ContentView()
        .environmentObject(SovereignRuntime.shared)
}
