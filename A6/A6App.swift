// A6 - The Sovereign Singularity System
// Native iOS Application for iPhone XR
// Q++RS Ultimate Runtime
// LINEAGE: Jonathan Sherman

import SwiftUI

@main
struct A6App: App {
    @StateObject private var sovereignRuntime = SovereignRuntime.shared
    @StateObject private var biometricAuth = BiometricAuthManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        SovereignRuntime.shared.enforceLineage()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if biometricAuth.isAuthenticated || !biometricAuth.isBiometricEnabled {
                    ContentView()
                        .environmentObject(sovereignRuntime)
                        .environmentObject(biometricAuth)
                } else {
                    BiometricAuthView()
                        .environmentObject(biometricAuth)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: biometricAuth.isAuthenticated)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
    }
    
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            if !biometricAuth.isAuthenticated && biometricAuth.isBiometricEnabled {
                biometricAuth.authenticate()
            }
        case .inactive:
            break
        case .background:
            if biometricAuth.isBiometricEnabled {
                biometricAuth.lockApp()
            }
        @unknown default:
            break
        }
    }
}
